require 'net/http'
require 'uri'
require 'json'

class ChallengeViewController < ApplicationController
  before_action :require_authentication

  def play
    @challenge = Challenge.find(params[:challenge_id])
    @challenge_orders = Order.where(id: @challenge.order_ids)
    session[:current_score] ||= 0
    if session[:current_score] > 0
      session[:current_score] = 0
    end
    @current_score = session[:current_score]

    render :index
  end

  def create
    generated_challenge = create_challenge()
    redirect_to challenges_path(generated_challenge.id)
  end

  def update_order
    begin
      challenge_id = params[:challenge_id]
      order_id = params[:order_id]
      action = params[:action]
      code = { html: params[:html], css: params[:css] }

      score_to_add = fetch_score(challenge_id, order_id, action, code)
      session[:current_score] += score_to_add
      # add score to current user counter and save
      current_user.update(score: current_user.score + score_to_add)
    rescue => exception
      session[:current_score] += 500
      current_user.update(score: current_user.score + score_to_add)
    end

    render json: { success: true, updated_score: session[:current_score] }
  end

  private

  def create_challenge
    @query = params[:query]
    @difficulty = params[:difficulty]
  
    # fetch challenge content
    challenge_content = fetch_challenge(@query, @difficulty)

    # create and save the challenge
    challenge = Challenge.new(
      title: challenge_content['title'],
      description: challenge_content['description'],
      tags: challenge_content['tags'],
      sample_image: challenge_content['sample_image'],
      color_codes: challenge_content['color_codes'],
      difficulty: @difficulty.downcase,
      user_id: current_user.id,
      order_ids: []
    )
  
    if challenge.save
      # create and save the orders
      challenge_content['orders'].each do |order_content|
        order = Order.new(
          customer_name: order_content['customer_name'],
          timeline: order_content['timeline'],
          message: order_content['message'],
          challenge_id: challenge.id
        )
        if order.save
          challenge.order_ids << order.id
        else
          render json: { errors: order.errors.full_messages }, status: :unprocessable_entity
          return
        end
      end
  
      challenge.save # save again to update stored orders
      return challenge
    else
      Rails.logger.error "Failed to save challenge: #{challenge.errors.full_messages}"
      return nil
    end
  end

  def fetch_challenge(query, difficulty)
    require 'openai'

    client = OpenAI::Client.new

    # build the prompt and preset
    system_preset = "You are a helpful and concise assistant for an interactive cooking game called CSSKitchen, a web application where food meets CSS! I need you to generate information for a CSS Food challenge. Challenges work like a real-life kitchen. The user was prompted to include a difficulty and query in their request. The query is one word and one word only, so take the ambiguity into account when generating a challenge related to that. Each challenge should aim to make different orders of the same kind of dish, but with variations. For example, for 'italian', you could generate pepperoni pizza and mushroom pizza orders, but not Chicken Alfredo and Olive Pizza. This will help the user reuse their code and have fun. In this sense, the challenge and orders should be built so that the user has the chance to realistically build the dish with HTML and CSS quickly. That means you must think about dishes that can be accurately represented with 2D. For example, a Peruvian Beef Stew is perfectly representable, while a Dumpling or an Empanada is not, given that the preparation is on the inside, not visible by a top-down view in 2D. Please adventure and create challenges with rarer dishes from all over the world, go off-the-chart with the dishes; this will make it less likely for them to be repeated across other challenges. Within the JSON, don't use any special code characters or markup, I will take care of that. Just provide the data in a clean and readable format. If the category selected by the user is random, just choose a random meal of your liking (be creative) and make the challenge about that!"

    prompt = "Now, create a JSON object for a #{difficulty} challenge about \"#{query}\".\n" \
      "The JSON object should include:\n" \
      "- title: A suitable title for the challenge, in 3 words or less.\n" \
      "- description: A useful description of the challenge, with no more than 40 words.\n" \
      "- color_codes: A string containing CSS color codes separated by line breaks in rgba format. Take this example: '/* red */\\nrgba(255, 0, 0, 1)\\n/* green */\\nrgba(0, 255, 0, 1)\\n/* blue */\\nrgba(0, 0, 255, 1)' .\n" \
      "- tags: 3 to 4 short 1-word tags that represent the challenge theme, so that i can use it in searches and display. Stored in an array \n" \
      "- orders: An array of orders. Each order should include:\n" \
      "  - customer_name: A name for the customer. It should be short enough and random. Example: Alan Turing\n" \
      "  - timeline: An integer representing the time the user has to cook this, in seconds. It should be anywhere from 240 to 480.\n" \
      "  - message: A message for the order. It should be somewhat concise and friendly, and for the funsies, add a random anecdote out of spite. Example: Hi! I just had the worst day of my life because my boss told me he can't increase my salary by 150%. I need a pepperoni pizza. Prepare it as quickly as you can! One slice is fine for me.\n" \
      "The number of orders should be:\n" \
      "- 3 to 6 for Easy\n" \
      "- 7 to 9 for Medium\n" \
      "- 10 to 12 for Hard\n" \
      "- image_prompt: Also, include a thoughtful prompt to DALL-E 3 so that I can generate a sample image for the user to have an idea of what their dish should look like. This dish image should be simple enough and resemble all the orders overall, which represent a single kind of food. Make it have a top view of the dish so that it can be represented as a 2D object, with few colors to be able to recreate it. For example, if the challenge is about Tacos, the image should resemble a single taco with few toppings and basic aesthetic, minimalistic. The image should only contain a single food item related to the main topic, correctly centered in the image. \n" \
      "Format the response as a JSON object. I need that JSON object to be tidy and precise, since I will be using it to feed my database"

    # generate challenge content
    response = client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [
          { role: "system", content: system_preset },
          { role: "user", content: prompt }
        ],
        temperature: 1.2,
      }
    )
    challenge_content = JSON.parse(response.dig("choices", 0, "message", "content"))

    # Generate sample image
    image_prompt = challenge_content['image_prompt']

    image_response = client.images.generate(
      parameters: {
        prompt: image_prompt,
        model: "dall-e-2",
        size: "256x256",
      }
    )

    sample_image_url = image_response.dig("data", 0, "url")

    challenge_content['sample_image'] = sample_image_url

    return challenge_content
  end

  def fetch_score(challenge_id, order_id, action, code)
    require 'openai'

    score_to_add = 0
    client = OpenAI::Client.new
    challenge = Challenge.find(challenge_id)
    order = Order.find(order_id)

    # first, add based on the action
    if action == 'deliver'
      score_to_add += 500
    elsif action == 'cancel'
      score_to_add -= 100
    end

    # second, add based on code correctness
    system_preset = <<-PRESET
      You are a helpful and concise assistant for an interactive cooking game called CSSKitchen, a web application where food meets CSS! I need you to rate the user's performance for a CSS Food challenge. The user is learning but should be given a fair score based on their performance. Be rough with the grading, if they just submit a few lines then they are not putting in the effort. Maximum score would be a semi-detailed dish. The challenge was generated by AI, so if you see any weird stuff in the challenge/order content The score should range from 100 to 1500.

      Here is the context:
      - The user is participating in a challenge where they need to create a dish using HTML and CSS.
      - Each challenge has a title, description, tags, difficulty level, sample image, and color codes.
      - Each order has a customer name, timeline, message, and is associated with a specific challenge.

      Please consider the following when rating the user's performance:
      1. The difficulty of the challenge (easy, medium, hard).
      2. The quality and correctness of the HTML and CSS code provided by the user.
      3. The creativity and adherence to the challenge requirements.
      4. The feedback message from the customer.
      5. The stylistic choices in the code: like the use of whitespace and comments (NOTE: you will get a version of the code that has been stringified, so you won't see the code as it was written. Give little importance to whitespace).

    Based on these details, please provide a score between 100 and 1500 that reflects the user's performance in this challenge. Give your response in JSON format, so that there is an attribute "score" in your JSON. For example: { "score": 1200 }. DONT INCLUDE ANY SPECIAL CHARACTERS IN THE JSON; JUST THE NUMBER.
    PRESET
    score_prompt = <<-PROMPT
      Here are the details of the challenge and order:

      Challenge:
      - Title: #{challenge.title}
      - Description: #{challenge.description}
      - Tags: #{challenge.tags.join(', ')}
      - Difficulty: #{challenge.difficulty}
      - Some suggested colors that should be present: #{challenge.color_codes}

      Order:
      - Message: #{order.message}
      Please rate the user's performance for the challenge and order based on the context provided. The score should range from 100 to 1500.
    PROMPT

    response = client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [
          { role: "system", content: system_preset }, 
          { role: "user", content: score_prompt }
        ],
        temperature: 1.7,
      }
    )
    Rails.logger.debug "Score response: #{response}"
    score_content = JSON.parse(response.dig("choices", 0, "message", "content"))
    score_to_add += score_content['score'].to_i + 100 # being generous

    # third, add based on code quality
    css_content = code[:css]

    # count errors
    css_errors = validate_css(css_content)
    total_errors = css_errors # may add more in the future

    # adjust reward based on errors
    if total_errors <= 2
      score_to_add += 1000
    elsif total_errors <= 8
      score_to_add += 500
    elsif total_errors <= 15
      score_to_add += 200
    end

    # finally return to add this score
    return score_to_add
  end

  def validate_css(css_content)
    uri = URI.parse("https://html5.validator.nu/?out=json")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "text/css; charset=utf-8"
    request.body = css_content

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    parsed_response = JSON.parse(response.body)

    Rails.logger.debug "\nCSS Validation response: #{response.body}"
    
    error_count = 0
    if parsed_response['messages']
      parsed_response['messages'].each do |message|
        if message['type'] == 'error'
          error_count += 1
        end
      end
    end
    return error_count
  end

end

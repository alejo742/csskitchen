# CSS Kitchen (live [here!](https://csskitchen.onrender.com))

## Welcome!

This is CSS Kitchen, a full-stack, interactive web application that helps beginners practice their CSS (and HTML) with fun food-based challenges. 

### How the idea came up

When I was a beginner to CSS, it took me long to memorize all the basic properties, and it felt like boring homework. I had to build ugly websites with no purpose just for the sake of practicing, and while it helped me improve, I believe there should be a funner way of doing it. That is CSS Kitchen!

### Additional information

I also designed the UI/UX for the app. Available on **Figma** [here](https://www.figma.com/design/5vPWVMeLFCcTmRH8ueeGVD/CSSKitchen?node-id=0-1&t=xE0tEjm1Ntk92U9r-1)

The free plan for [Render](https://render.com) (the hosting platform for this project) downtimes the web server after 15 minutes of inactivity. Meaning that chances are you have to wait a little bit the first time you access the deployed app, until the server turns back on. After that, loading time is normal.

Credentials and necessary information should be accessible to anyone reading this. If you encounter any problems when trying to set up the project, please reach out to [me](mailto:alejandro.s.manrique.nunez.28@dartmouth.edu) and I will answer immediately.

## Running the app locally

### Prerequisites

Before running this project, ensure you have the following installed:

- Ruby 3.3.4 (the exact version specified in `.ruby-version`)
- Bundler
- Node.js LTS and Yarn (preferred)
- PostgreSQL 16

*If you encounter any issues during installation, go to the last section of this document.*

### Setup Instructions (bash)

1. **Clone the repository:**

    In a directory of your liking, run:

	```bash
	git clone https://github.com/alejo742/csskitchen.git
	cd csskitchen
	```

2. **Set up credentials**

    As specified in the `config/database.yml` file, the authorized database user is `csskitchen`, and its password is digged from the encrypted credentials file. Other private keys are also stored in the credentials file. For the database and services to work, you must:

    1. Create a new PostgreSQL user called `csskitchen`:

        With PostgreSQL installed, access your PSQL terminal with your admin user and run the following command:

        ```sql
        CREATE USER csskitchen WITH PASSWORD 'csskitchen742';
        ```

        Then, give it permission to create our database:

        ```sql
        ALTER USER csskitchen CREATEDB;
        ```
    
    2. Place the decryption master key within the `config` directory:

        Download the file from [here](https://drive.google.com/file/d/17K4wkYhXgf4bmKNei4g-SYL6-cBY1Iy9/view?usp=sharing)

    With this, Rails should be able to decrypt the credentials and access the database

3. **Install dependencies:**

    Run the setup file at "bin/setup":

	```bash
	bin/setup
	```

4. **Set up the database:**

	Ensure PostgreSQL is running and setup the database:

	```bash
	rails db:setup
	```

5. **Run the application locally:**

	```bash
	rails server
	```

### Troubleshooting

- **Bundler issues**

    If you find an error related to Bundler, try running:

    ```bash
    gem install bundler
    bundle install
    ```

- **Database issues (with Linux)**

    If you are using a Debian distribution of Linux, check for running clusters:

    ```bash
    pg_lsclusters
    ```
    
    and then restart the service if anything seems odd:

    ```bash
    sudo service postgresql restart
    ```

- **Dependency issues**

    If you are missing any project dependencies, run:

    ```bash
    bundle install
    ```

- **Other issues**

    Please refer to the getting-started documentation of Ruby, Rails or PostgreSQL for your operating system.

    - Installing Ruby: [link](https://www.ruby-lang.org/en/documentation/installation/)

    - Installing PostgreSQL: [link](https://www.postgresql.org/download/)

    - Installing NodeJS: [link](https://nodejs.org/en)

    - A checklist to setting up a cloned Rails project (most steps are not necessary though): [link](https://dev.to/w3ndo/a-checklist-for-setting-up-a-cloned-rails-application-locally-5468)
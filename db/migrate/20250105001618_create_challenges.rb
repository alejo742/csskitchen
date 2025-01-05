class CreateChallenges < ActiveRecord::Migration[7.1]
  def change
    create_table :challenges do |t|
      # basic display values for challenges
      t.string :title, null: false
      t.string :description, null: false
      t.string :tags, array: true, default: []
      t.string :difficulty, null: false
      t.string :image_banner
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    # Add a check constraint for the difficulty column
    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE challenges
          ADD CONSTRAINT difficulty_check
          CHECK (difficulty IN ('easy', 'medium', 'hard'))
        SQL
      end

      dir.down do
        execute <<-SQL
          ALTER TABLE challenges
          DROP CONSTRAINT difficulty_check
        SQL
      end
    end
  end
end
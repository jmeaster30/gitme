require 'sequel' 

Sequel.migration do
  up do
    create_table(:user) do
      primary_key :id
      String :name, null: false
      DateTime :created_at, null: false

      unique :name
    end

    create_table(:repository) do
      primary_key :id
      String :name, null: false
      DateTime :created_at, null: false

      foreign_key :user_id, :user

      unique [:name, :user_id]
    end
  end

  down do
    drop_table(:repository)
    drop_table(:user)
  end
end
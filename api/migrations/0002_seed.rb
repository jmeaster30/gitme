require 'sequel' 

Sequel.migration do
  up do
    from(:user).insert(id: 1, name: 'me', password: '$2a$12$TaAlY3wtBpLdNCd.mrnvVufAJy9O8ASzAyq6M/2AvDHJjqaEN4pSa', created_at: DateTime.now)
  end

  down do
    from(:user).delete
  end
end
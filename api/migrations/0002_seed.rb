require 'sequel' 

Sequel.migration do
  up do
    from(:user).insert(id: 1, name: 'me', password: 'password', created_at: DateTime.now)
  end

  down do
    from(:user).delete
  end
end
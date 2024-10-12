require 'sequel' 

Sequel.migration do
  up do
    from(:user).insert(id: 1, name: 'me', password: 'password', created_at: DateTime.now)
    from(:repository).insert(id: 1, name: 'gitme', user_id: 1, created_at: DateTime.now)
  end

  down do
    from(:repository).delete
    from(:user).delete
  end
end
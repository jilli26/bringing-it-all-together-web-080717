require 'pry'

class Dog

attr_accessor :name, :breed, :id


def initialize(name:, breed:, id: nil)
  @name = name
  @breed = breed
  @id = id
end

def self.create_table
  DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)")
end

def self.drop_table
  DB[:conn].execute("DROP TABLE IF EXISTS dogs")
end

def save
  sql = <<-SQL
    INSERT INTO dogs (name, breed)
    VALUES (?, ?)
  SQL

  DB[:conn].execute(sql, self.name, self.breed)

  results = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")
  @id = results.flatten.first
  self.id = @id
  self
end

def self.create(attributes)
  new_dog = self.new(attributes)
  new_dog.save
end

def self.find_by_id(dog_id)
  sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE id = ?
    ;
  SQL

  dog_row = DB[:conn].execute(sql, dog_id)
  dog_row.flatten!
  new_dog = Dog.new(id: dog_row[0], name: dog_row[1], breed: dog_row[2])
end

def self.find_or_create_by(attributes)
  sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name = ? and breed = ?
    ;
  SQL

  dog_row = DB[:conn].execute(sql, attributes[:name], attributes[:breed])
  if dog_row.empty?
    self.create(attributes)
  else
    dog_row.flatten!
    new_dog = Dog.new(id: dog_row[0], name: dog_row[1], breed: dog_row[2])
  end
end

def self.new_from_db(dog_row)
  new_dog = Dog.new(id: dog_row[0], name: dog_row[1], breed: dog_row[2])
end

def self.find_by_name(name)
  sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name = ?
    ;
  SQL

  dog_row = DB[:conn].execute(sql, name)
  dog_row.flatten!
  self.new_from_db(dog_row)
end

def update
  sql = <<-SQL
  UPDATE dogs
  SET name = ?,
  breed = ?
  WHERE id = ?
  SQL

DB[:conn].execute(sql, self.name, self.breed, self.id)
end

end

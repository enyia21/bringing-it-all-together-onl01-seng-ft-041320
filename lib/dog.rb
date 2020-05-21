require 'pry'
class Dog

    attr_accessor :id, :name, :breed 

    def initialize(name:, breed:, id: nil) 
        @name = name
        @breed = breed 
        @id = id
    end

    def self.create_table
        sql = <<-SQL
                CREATE TABLE 
                dogs(id Integer PRIMARY KEY,
                name TEXT, 
                breed TEXT)
                SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
                DROP TABLE
                dogs
                SQL
                DB[:conn].execute(sql)
    end

    def save
        if self.id 
            self.update
        else
            sql = <<-SQL
                    INSERT INTO dogs(name, breed)
                    VALUES (?, ?)
                    SQL
                    DB[:conn].execute(sql, self.name, self.breed)
                    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs").flatten[0]
                    self
        end
    end

    def self.create(name:, breed:)
        
        new_dog = self.new(name: name, breed: breed)
        new_dog.save
    end

    def self.new_from_db(row)    
        # binding.pry

        new_dog = self.new(id: row[0], name: row[1], breed: row[2])
        new_dog
    end

    def self.find_by_id(passed_id)
        sql = "SELECT * FROM dogs WHERE id = ?"
        result = DB[:conn].execute(sql, passed_id)[0]
        Dog.new(id: result[0],name: result[1],breed: result[2])
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
                SELECT * FROM dogs
                WHERE name = ? AND breed = ? 
            SQL
        dog_id = DB[:conn].execute(sql, name, breed).flatten[0]

        if dog_id
            self.find_by_id(dog_id)
        else
            dog = self.create(name: name, breed: breed)
            dog.save
            dog
        end
            
    end

    def update
        sql = <<-SQL
                UPDATE dogs SET name = ?,
                breed = ?  WHERE id = ?
                SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def self.find_by_name(name)
        sql = <<-SQL
                    SELECT * FROM dogs
                    WHERE name = ?
                SQL
          dog = DB[:conn].execute(sql, name).flatten
          binding.pry
            self.new_from_db(dog)
    end
end 
class Dog
    attr_accessor :name, :breed, :id

    def initialize(hash_of_attributes)
        @name = hash_of_attributes[:name]
        @breed = hash_of_attributes[:breed]
        @id = hash_of_attributes[:id]
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY, 
                name TEXT, 
                breed TEXT
            )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs")
    end

    def self.new_from_db(row)
        new_dog = Dog.new({name: row[1], breed: row[2]}) 
        new_dog.id = row[0]
        new_dog  
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1"
        DB[:conn].execute(sql, name).map do |row|
            self.new_from_db(row)
        end.first
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ? LIMIT 1"
        DB[:conn].execute(sql, id).map do |row|
            self.new_from_db(row)
        end.first
    end

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if !dog.empty?
            dog_data = dog[0]
            dog = Dog.new({id: dog_data[0], name: dog_data[1], breed: dog_data[2]})
        else
            dog = self.create(name: name, breed: breed)
        end
        dog
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(hash_of_attributes)
        new_dog = Dog.new(hash_of_attributes)
        new_dog.save
        new_dog
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end
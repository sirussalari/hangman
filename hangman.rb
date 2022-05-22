class Player
    @@incorrect_letters = []
    @@instance = nil

    attr_reader :name

    def initialize(name, version = nil)
        @@instance = self
        @name = name
        @version = version

        if version != nil
            Computer.start_game(version)

        else
            Display.count
            Display.incorrect_letters
        end

        Display.correct_letters
        Computer.prompt_guess
    end

    def self.incorrect_letters
        return @@incorrect_letters
    end

    def self.load_incorrect_letters(incorrect_letters)
        @@incorrect_letters = incorrect_letters
    end

    def self.instance
        return @@instance
    end
end

class Computer
    @@word = nil

    def self.word
        return @@word
    end

    def self.load_word(word)
        @@word = word
    end

    def self.start_game(version)

        if version == 'clean'
            @@word = Computer.random_word('google-10000-english-no-swears.txt')

        elsif version == 'nsfw'
            @@word = Computer.random_word('google-10000-english.txt')
        end
    end

    def self.random_word(file_name)
        file = File.read(file_name)
        file = file.split

        random_word = nil
        loop do
            index = Random.rand(file.length)
            random_word = file[index]

            if random_word.length >= 5 and random_word.length <= 12
                break
            end
        end

        return random_word
    end

    def self.prompt_guess
        puts "To save the game, type 'save'\nGuess a letter or word"
        guess = gets.chomp
        guess.downcase!

        if guess == "save"
            Computer.save_game
        else
            Computer.guess_correct?(guess)
        end
    end

    def self.guess_correct?(letter)

        if letter.length > 1
            if letter == Computer.word
                Display.count
                puts "You got the word right! The word is #{letter}"
                return true
            else
                puts "Nope! The word is not #{letter}"
                Display.count(true)
                Display.incorrect_letters
                Display.correct_letters
            end

        else
            if !Computer.word.include?(letter)
                if !Player.incorrect_letters.include?(letter)

                    Player.incorrect_letters.push(letter)
                end

                Display.count(true)
                Display.incorrect_letters
                Display.correct_letters

            else
                word = Computer.word
                word_array = word.split('')

                indices = []
                for index in 0...word.length

                    if word[index] == letter
                        indices.push(index)
                    end
                end

                Display.count
                Display.incorrect_letters
                Display.correct_letters(letter, indices)
                
            end
        end

        if !Display.game_over?
            Computer.prompt_guess
        end
    end

    def self.save_game
        if !Dir.exist?('saved-games')
            Dir.mkdir('saved-games')
        end

        Data.add_data(:name, Player.instance.name)
        Data.add_data(:hidden, Display.hidden)
        Data.add_data(:incorrect_letters, Player.incorrect_letters)
        Data.add_data(:word, Computer.word)

        serialized_data = Marshal.dump(Data.saved_data)

        if File.file?("saved-games/#{Player.instance.name}1.dump")
            puts "It looks like you already have a saved game, #{Player.instance.name}"
            puts "Would you like to overwrite your saved game (type 'overwrite') or create a new saved game (type 'new')?"

            response = gets.chomp
            
            if response == 'overwrite'
                puts 'Which iteration would you like to overwrite?'
                iteration =  gets.chomp

                File.delete("saved-games/#{Player.instance.name}#{iteration}.dump")

                file = File.open("saved-games/#{Player.instance.name}#{iteration}.dump", 'wb')

                file.write(serialized_data)

                file.close

            elsif response == 'new'
                iteration = 2

                while File.file?("saved-games/#{Player.instance.name}#{iteration}.dump")
                    iteration += 1
                end

                file = File.open("saved-games/#{Player.instance.name}#{iteration}.dump", 'wb')
                file.write(serialized_data)
                file.close

                puts "Your game has been saved with an iteration value of #{iteration}"
            end
        else

            file = File.open("saved-games/#{Player.instance.name}1.dump", 'wb')

            file.write(serialized_data)

            file.close

            puts "Your game has been saved with an iteration value of 1"
        end
    end
end

class Display
    @@guess_number = 0
    @@hidden = []

    def initialize 
    end

    def self.hidden
        return @@hidden
    end

    def self.load_hidden(hidden)
        @@hidden = hidden
    end

    def self.load_guess_number(guess_number)
        @@guess_number = guess_number
    end

    def self.count(incorrect = false)
        if incorrect
            @@guess_number += 1
        end

        phrase = "Incorrect Guesses: #{@@guess_number}/6"
        puts phrase
    end

    def self.correct_letters(letter = nil, indices = nil)
        if @@hidden.empty?
            amount_of_letters = Computer.word.length

            for i in 0...amount_of_letters
                @@hidden.push('_')
            end

            @@hidden = @@hidden.join(' ')

        else
            if letter
                @@hidden = @@hidden.split
                
                for index in indices
                    @@hidden[index] = letter
                end

                @@hidden = @@hidden.join(' ')
            end
        end

        puts @@hidden
    end

    def self.incorrect_letters
        phrase = "Letters not in the word: #{Player.incorrect_letters.join(',')}"
        puts phrase
    end

    def self.game_over?
        if @@guess_number == 6
            puts "The word is #{Computer.word}"
            return true

        elsif !@@hidden.include?('_')
            puts "Congrats!"
            return true
        end

        return false
    end
end

class Data
    @@saved_data = {}

    def self.saved_data
        return @@saved_data
    end

    def self.add_data(key, value)
        Data.saved_data[key] = value
    end
end

puts "Hello! What is your name?"
name = gets.chomp

if File.exist?("saved-games/#{name}1.dump")
    puts "It looks like you already have at least one saved game"
    puts "Would you like to load a saved game (type 'load') or start a new game (type 'new')?"

    response = gets.chomp

    if response == 'load'
        deserialized_data = nil

        if File.exist?("saved-games/#{name}2.dump")
            puts "Which saved game would you like to open (type the assigned iteration number)"
            iteration = gets.chomp
    
            deserialized_data = Marshal.load(File.open("saved-games/#{name}#{iteration}.dump"))
    
        else
            deserialized_data = Marshal.load(File.open("saved-games/#{name}1.dump"))
        end
    
        Computer.load_word(deserialized_data[:word])
        Player.load_incorrect_letters(deserialized_data[:incorrect_letters])
        Display.load_hidden(deserialized_data[:hidden])
        Display.load_guess_number(deserialized_data[:incorrect_letters].length)
        player = Player.new(name)

    else
        puts "Would you like to play a clean version or NSFW version?(type 'clean' or 'nsfw')"
        version = gets.chomp

        player = Player.new(name, version)
        
    end

else
    puts "Would you like to play a clean version or NSFW version?(type 'clean' or 'nsfw')"
    version = gets.chomp

    player = Player.new(name, version)
end
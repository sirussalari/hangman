class Player
    @@incorrect_letters = []

    def initialize(name, version)
        @name = name
        @version = version
        Computer.start_game(version)
        Display.correct_letters
        Computer.prompt_guess
    end

    def self.incorrect_letters
        return @@incorrect_letters
    end
end

class Computer
    @@word = nil

    def initialize
    end

    def self.word
        return @@word
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
        puts "Guess a letter or word"
        guess = gets.chomp
        guess.downcase!

        Computer.guess_correct?(guess)
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
end

class Display
    @@guess_number = 0
    @@hidden = []

    def initialize 
    end

    def self.hidden
        return @@hidden
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

#puts "Hello! What is your name?"
#name = gets.chomp

#puts "Hey #{name}! Would you like to play a clean version or NSFW version?(type 'clean' or 'nsfw')"
#version = gets.chomp

version = 'clean'
name = 'sirus'

player = Player.new(name, version)
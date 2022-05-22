# hangman

This project is an assignment part of the Odin Project Curriculum.

In this project, I created a Ruby based program for playing Hangman in the Terminal.

The program starts by collecting your name and whether you'd like to play a "clean" or "not safe for work" version of the game. Based on your input, the program then opens the appropiate text file containing thousands of words. The program then chooses a random word that is between 5-12 letters long.

The display in the terminal shows how many more incorrect guesses you're allowed, which letters you've guessed that are not in the word, and a string of underscores that match the amount of letters in the word. Each time you guess a correct letter, the program replaces the correct underscore(s) index with the letter. A player also has the option of guessing the entire word at any point in the game. If you guess the word correctly or get all the correct letters before running out of guesses, then the program congratulates you and closes. If you run out of guesses, then the program reveals what the word is.

At any point in the game, the player has the option of saving the game. If they choose to save the game, the program checks to see if the player already has a saved game. If they do, then the program asks if they would like to overwrite a saved game, or create a new saved game; each saved game that is attached to a player is uniquely identifiable through an assigned iteration value which naturally increments by 1 each time the player creates a new saved game. For convenience, the program prints the iteration number to the Terminal after it has ben saved. The program stores all of the saved games into a subfolder.

Each time that the program is ran, the program checks to see if the player already has a saved game based on the name that they enter. If the player already has at least one saved game, then the program lets them know and asks if they would like to load a saved game or start a new game. If they choose to load a game, they're prompted to choose which iteration they would like to load.

The process of saving the game is done in 3 main steps:

  -First, there's a class called "Data" which contains a class variable called "saved_data" which is an object. The "Data" class also has two class
  methods; one method is simply meant to return the "saved_data", and the other is meant to add key-value pairs to the "saved_data" object based on arguments that are passed in when its called. When the player chooses to save the game, the class method for adding data is called to add in the name of the player, the correct letters guessed, the incorrect letters guessed, and the word that you have to guess.
  
  -Next, the program then takes the "saved_data" object that now contains all of the valid data and serializes the object using the Marshal module.
  
  -Finally, the program creates (or overwrites) a file and writes the serialized data.
  
The process of loading a game is done in 2 main steps:

  -First, the program deserializes the data using the Marshal module.
  
  -Next, the program loads all of the data into their appropiate variables through setter methods that I defined.

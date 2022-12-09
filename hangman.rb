require 'yaml'

class ChooseWord
  attr_reader :word
  def initialize
    @word = find_word
  end

  def find_word
  dictionary = File.readlines('dictionary.txt')
    loop do
      word = dictionary[rand(dictionary.length)].strip.downcase
      return word if word.length >= 5 && word.length <= 12
    end
  end
end

class Game
  def initialize
    @chosen_word = ChooseWord.new
    @guessed_word = "_" * @chosen_word.length
    @num_of_guesses_left = 8

  end

  #welcome player to the game and ask how they want to proceed
  def game_welcome
    puts "Welcome to Hangman"
    puts "Please indicate how you'd like to proceed"
    puts "1 - New Game"
    puts "2 - Load Game"
    game_choice = gets.chomp
    welcome_choice(game_choice)
  end

  def welcome_choice(game_choice)
    if game_choice == 1
      play_game
    elsif game_choice == 2
      load_game
    else
      puts "Invalid choice, please choose again"
    end
  end

  #play game
  def play_game
    until @num_of_guesses_left == 0

  end

  #guess prompt 
  def guess_prompt
  end

  #check if guess is valid
  def valid_guess?
  end

  #save current game
  def save_game
  end

  #load a previous game
  def load_game
  end

  #check if game has been won
  def game_won?
  end

  #saved game menu
  def saved_games
  end
  
  def deserialize
  end

end
game = Game.new
game.game_start
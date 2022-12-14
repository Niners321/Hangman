require 'yaml'


Psych::ClassLoader::ALLOWED_PSYCH_CLASSES = [ 'Game' ]

module Psych
  class ClassLoader
    ALLOWED_PSYCH_CLASSES = [] unless defined? ALLOWED_PSYCH_CLASSES
    class Restricted < ClassLoader
      def initialize classes, symbols
        @classes = classes + Psych::ClassLoader::ALLOWED_PSYCH_CLASSES.map(&:to_s)
        @symbols = symbols
        super()
      end
    end
  end
end

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
  attr_accessor :chosen_word, :guessed_word, :num_of_guesses_left, :player_guesses
  def initialize
    @chosen_word = ChooseWord.new.word
    @guessed_word = "_" * @chosen_word.length
    @num_of_guesses_left = 8
    @player_guesses = String.new
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
    if game_choice == '1'
      play_game
    elsif game_choice == '2'
      load_file
    else
      puts "Invalid choice, please choose again"
    end
  end

  #play game
  def play_game
    until @num_of_guesses_left == 0
      guess = guess_prompt
      @player_guesses << guess + " "
      check_guess(guess)
      break if game_won?(@chosen_word, @player_word)
    end
    game_over
  end

  #initial guess prompt 
  def initial_prompt
    puts 'Save your game by typing the word "save".'
    puts "You have #{num_of_guesses_left} guesses remaining"
    puts "Your guessess so far: #{@player_guesses}"
    puts "Your word has #{guessed_word.length} letters"
    puts guessed_word
  end

  #guess promp in ongoing game
  def guess_prompt
    initial_prompt
    loop do
      puts "Enter your guess:"
      guess = gets.chomp.downcase
      if valid_guess?(guess)
        return guess
      else
        puts "Letter already guessed, choose a new letter"
        initial_prompt    
      end
      save_game if guess.downcase == 'save'
      break
    end
    guess_prompt
  end

  #check if guess is valid
  def valid_guess?(guess)
    if ("a".."z").include?(guess) && !@player_guesses.include?(guess)
      return true
    elsif ("a".."z").include?(guess) && @player_guesses.include?(guess)
      return false
      puts "Letter already guessed, choose a new letter"
      guess_prompt
    end
  end

  #check if guess is in @chosen_word
  def check_guess(guess)
    chosen_word.length.times do |i|
      @guessed_word[i] = guess if guess == chosen_word[i]
    end
    self.num_of_guesses_left -= 1 unless chosen_word.include?(guess)
  end

    #check if game has been won
  def game_won?(chosen_word, guessed_word)
     @chosen_word == @guessed_word
  end
  
  
    #game over messages
  def game_over
    puts "Congrats! You got the word! #{chosen_word}" if game_won?(chosen_word, guessed_word)
    puts "You lose, better luck next time! /nThe word was: #{chosen_word}" unless game_won?(chosen_word, guessed_word)
  end

  #save current game
  def save_game
    puts 'Enter the name of your save file: '
    save_file = gets.chomp
    Dir.mkdir('saved_games') unless Dir.exist?('saved_games')
    File.open("./saved_games/#{save_file}.yml", 'w') { |file| file.write save_to_yaml }
    exit
  end
  
  def save_to_yaml
    YAML.dump(
    'chosen_word' => @chosen_word,
    'guessed_word' => @guessed_word,
    'num_of_guesses_left' => @num_of_guesses_left,
    'player_guesses' => @player_guesses,
    )
  end

  
  #saved games menu
  def load_file
    games = saved_games
    puts games
    puts 'Enter which saved_game would you like to load: '

    load_file = gets.chomp
   

    load_game = File.read("./saved_games/#{load_file}.yml")
    load_game = deserialize(load_game)
    return load_game if games.include?(load_file)
  end
  
  
  def deserialize(game)
    file = YAML.load_file("./saved_games/#{game}.yml")
    @chosen_word = file['chosen_word']
    @guessed_word = file['guessed_word']
    @num_of_guesses_left = file['num_of_guesses_left']
    @player_guesses = file['player_guesses']
  end
  
  def saved_games
    puts 'Saved games: '
    Dir['./saved_games/*'].map { |file| file.split('/')[-1].split('.')[0] }
  end

end

new_game = Game.new
new_game.game_welcome
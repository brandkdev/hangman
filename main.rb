# six tries 
# save File
require 'yaml'

class Game
  def initialize
    @valid_words = File.readlines('google-10000-english-no-swears.txt')
    @words_array = []
    @valid_words.each do |word|
      correct_length_word = word.strip if word.strip.length.between?(5, 12)
      @words_array.push(correct_length_word)
      @words_array.compact!
    end
    @wrong_guesses = 0
    load_game
  end

  def start
    @chosen_word = @words_array.sample
    puts @chosen_word
    @blank_letters = []
    i = 0
    while i < @chosen_word.length
      @blank_letters.push('_ ')
      i += 1
    end
    puts @blank_letters.join('')
    @player = Player.new(self)
    @player.player_input
  end

  def check_guess(guess)
    @correct_letters = @chosen_word.split('')
    @correct_letters.each_with_index do |letter, index|
      if guess == letter
        @blank_letters[index] = guess + ' '
      else next
      end
    end
    if @correct_letters.none? { |letter| letter == guess}
      @wrong_guesses += 1
    end
    @correct_guess = @blank_letters.map { |letter| letter.strip}
    if @correct_guess.join('') == @chosen_word
      puts 'You win!'
      game_over
    end
    if @wrong_guesses == 6
      puts 'You lose!'
      game_over
    end
    puts "#{@blank_letters.join('')}    Wrong Guesses: #{@wrong_guesses} / 6"
  end

  def display
    puts "#{@blank_letters.join('')}    Wrong Guesses: #{@wrong_guesses} / 6"
    @player.player_input
  end

  def game_over
    puts "Would you like to play again? Enter 'y' for yes, anything else for no."
    @response = gets.chomp
    if @response == 'y'
      Game.new.start
    else exit(true)
    end
  end

  def save_game
    File.open("./hangman.yml", 'w') { |f| YAML.dump([] << self, f) }
    exit
  end

  def load_game
    begin
      yaml = YAML.load_file("./hangman.yml")
      @wrong_guesses = yaml.wrong_guesses
      @chosen_word = yaml.chosen_word
      @blank_letters = yaml.blank_letters
      @correct_letters = yaml.correct_letters
      @correct_guess = yaml.correct_guess
    rescue
      @history = []
    end
    puts @chosen_word
  end
end

class Player
  
  def initialize(game)
    @game = game
  end
  
  def player_input
    puts "enter a single letter as your guess, enter '!save' to save your game and exit."
    @guess = gets.chomp.downcase
    if @guess == '!save'
      @game.save_game
    elsif @guess.length != 1
      puts 'your entry must be one letter only'
      player_input
    else @game.check_guess(@guess)
    end
  end
end

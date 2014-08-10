class Hangman

  def initialize(guessing_player, checking_player)
    @guessing_player = guessing_player
    @checking_player = checking_player
    @words = IO.readlines("dictionary.txt").map{ |word| word.chomp }
  end

  def run
    @secret_word = @checking_player.pick_secret_word
    # for test for phase 1
    #p @secret_word
    
    print "Secret word: ", "_" * @secret_word.length, "\n"
    @guessing_player.create_first_candidate(@secret_word.length)

    until over? 
      guess = @guessing_player.guess
      @checking_player.render_guess(guess)
      @guessing_player.update_candidates(@checking_player.correct_answers)
    end
  end
  
  def over?
    correct_answers = @checking_player.correct_answers
    correct_answer_count = 0
    correct_answers.each_key do |chr|
      correct_answer_count += correct_answers[chr].length
    end  
    if correct_answer_count == @secret_word.length  
      print "guessor won!\n"
      return true
    else
      return false
    end
  end
    
end

class HumanPlayer
  attr_reader :correct_answers
  def initialize
    @correct_answers = Hash.new{|h,k| h[k] = []}
  end
  
  # phase1 
  def guess
    print "Input your guess!: "
    input = gets.chomp
  end

  def check_guess(guess)
  end
  
  def pick_secret_word
    print "Input Secret word length "
    word_length = Integer (gets.chomp!)
    @secret_word = "_"*word_length
  end
  
  def handle_guess_response(guess)
    input = gets.chomp
    if input != "no"
      correct_positions = input.split(" ").map{|el|el.to_i}
      @correct_answers[guess] = correct_positions
    end
  end

  def render_guess(guess)
    handle_guess_response(guess)
    
    default_value = "_" *@secret_word.length
    @correct_answers.each_key do |chr|
      positions_array = @correct_answers[chr] 
      positions_array.each do |position|
        default_value[position] = chr
      end
    end
    print "Secret word: ", default_value, "\n"
  end
  
  def create_first_candidate(n)
  end

  def update_candidates(n)
  end
end

class ComputerPlayer
  attr_reader :correct_answers
  def initialize
    @correct_answers = Hash.new{|h, k| h[k] = []}
    @words = IO.readlines("dictionary.txt").map{ |word| word.chomp }
  end
  
  def pick_secret_word
    @secret_word = @words.sample
    @secret_word
  end
 
  def check_guess(guess)
    return true if @secret_word.split("").include?(guess)
    return false
  end

  def handle_guess_response(guess)
    positions = []
    @secret_word.split("").each_with_index do |chr, idx|
      positions << idx if chr == guess
    end
    @correct_answers[guess] = positions
  end
 
  def render_guess(guess)
    if check_guess(guess) == false
      print "guess is wrong!\n" 
    else
      handle_guess_response(guess)
    end  
    default_value = "_"*@secret_word.length
    
    @correct_answers.each_key do |chr|
      positions_array = @correct_answers[chr] 
      positions_array.each do |position|
        default_value[position] = chr
      end
    end
    print "Secret word: ", default_value, "\n"
  end

  def words_frequency_chr(words)
    counter = Hash.new(0)
    words.each do |word|
      word.split("").each do |chr|
        counter[chr] += 1
      end
    end
    counter
  end
  def most_frequent_new_chr(words)
    counter = words_frequency_chr(words)
    sorted = counter.sort_by{ |key, value| -value}
    sorted.each do |elem|
      return elem[0] unless @guessed_chrs.include?(elem[0])
    end
    return "error"
  end

  def create_first_candidate(n)
    @current_candidates = @words.select{ |word| word.length == n}
    @guessed_chrs = []
  end

  def guess
   @guess_chr = most_frequent_new_chr(@current_candidates)
   @guessed_chrs << @guess_chr
   print "Computer's guess: ", @guess_chr, "\n"
   @guess_chr
  end
  # needs guess_chr and input from user
  # correct_answers: {"a"=> [0,4], "b"=>[1,2,3]...}
  def update_candidates(correct_answers)
    @current_candidates.each do |candidate|
      @current_candidates.delete(candidate) unless match(candidate, correct_answers)
    end
    @current_candidates
  end

  def match(candidate, correct_answers)
    correct_answers.each_key do |chr|
      correct_answers[chr].each do |idx|
        return false unless candidate[idx] == chr 
      end
    end
    return true
  end
end

#c = ComputerPlayer.new
#p secret_word = c.pick_secret_word
#p a = c.check_guess("e")
#c.handle_guess_response("e")

h = HumanPlayer.new
c = ComputerPlayer.new
game = Hangman.new(c, h)
game.run

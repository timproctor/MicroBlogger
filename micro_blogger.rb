require 'jumpstart_auth'
require 'klout'
require 'bitly'

class MicroBlogger
  attr_reader :client

  def initialize
    puts "Ok, here we go..."
    @client = JumpstartAuth.twitter
    Klout.api_key = 'xu9ztgnacmjx3bu82warbr3h'
  end

  def tweet(message)
    if message.length <= 140
      @client.update(message)
    else
      raise ArgumentError.new("Yo, only 140 or less, come on...you know this!")
    end
  end

  def run
    puts "Welcome to the JSL Twitter Client!"
    input = ""
      while input != "q"
        printf "enter input: "
        input = gets.chomp
        parts = input.split(" ")
        command = parts[0]
        case command
          when 'q'
            puts "See ya real soon...right?"
          when 't'
            tweet(parts[1..-1].join(" "))
          when 'dm'
            dm(parts[1], parts[2..-1].join(" "))
          when 'spam'
            spam_my_followers(parts[1..-1].join(" "))
          when 'elt'
            everyones_last_tweet
          when 's'
            shorten(parts[1..-1].join(" "))
          when 'turl'
            tweet(parts[1..-2].join(" ") + " " + shorten(parts[-1]))
          else
            puts "What does #{input} mean? try again."
        end
      end
  end

  def dm(target, message)
    #Find the list of my followers
    screen_names = @client.followers.collect{|follower| follower.screen_name}
    followers = screen_names.include?(target)
    #If the target is in this list, send the DM
    if followers
      tweet("d #{target} #{message}")
    else
    #Otherwise, print an error message
      puts "They ain't following you, yo!"
    end
    puts "I'm sending #{target} this direct message:"
    puts message
  end

  def spam_my_followers(message)
      # Define the method named spam_my_followers with a parameter named message
      # Get the list of your followers from the followers_list method
      followers_list.each do |friend|
         dm(friend, message)
      end
      # Iterate through each of those followers and use your dm method to send them the message
  end

  def followers_list
    screen_names = Array.new
    followers_list = @client.followers.each{|follower| screen_names << follower["screen_name"] }
    screen_names
  end

  def everyones_last_tweet
    friends = @client.friends.sort_by do |friend|
      friend.screen_name.downcase
    end

    friends.each do |friend|
      timestamp = friend.status.created_at
      puts "#{friend.screen_name} said this on #{timestamp.strftime("%A, %b %d")}...\n#{friend.status.text}"
    end
  end

  def shorten(original_url)
    Bitly.use_api_version_3
    bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
    bitly_shorten = bitly.shorten(original_url)
    puts "Shortening this URL: #{bitly_shorten}"
    puts "#{bitly_shorten.short_url}"
    bitly_shorten.short_url
  end

  def klout_score
    friends = @client.friends.map do |friend|
      friend.screen_name
    end

    friends.each do |friend|
      begin
        identity = Klout::Identity.find_by_screen_name(friend)
        user = Klout::User.new(identity.id)
          puts "\n#{friend} scored: #{user.score.score}"
          rescue Klout::NotFound
            "Could not find #{friend}"
      end
    end
  end
end

blogger = MicroBlogger.new
# blogger.tweet("testing")
# blogger.run
# blogger.everyones_last_tweet
blogger.klout_score

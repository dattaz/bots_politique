require 'twitter_ebooks'
require 'open-uri'
# Information about a particular Twitter user we know
class UserInfo
  attr_reader :username

  # @return [Integer] how many times we can pester this user unprompted
  attr_accessor :pesters_left

  # @param username [String]
  def initialize(username)
    @username = username
    @pesters_left = 1
  end
end

class CloneBot < Ebooks::Bot
  attr_accessor :original, :model, :model_path

  def configure
    # Configuration for all CloneBots
    self.consumer_key = "YOUR KEY HERE"
    self.consumer_secret = "YOUR KEY HERE"
    self.blacklist = ['kylelehk', 'friedrichsays', 'Sudieofna', 'tnietzschequote', 'NerdsOnPeriod', 'FSR', 'BafflingQuotes', 'Obey_Nxme']
    self.delay_range = 1..6
    @userinfo = {}
  end
  def on_mention(tweet)
    # Become more inclined to pester a user when they talk to us
    #userinfo(tweet.user.screen_name).pesters_left += 1
    delay do
      if meta(tweet).mentionless.include? ":" and meta(tweet).mentionless.partition(':').last.gsub(/\s+/, "") == "next"
        make_a_statement(meta(tweet).mentionless.split(":")[0], tweet)
      elsif meta(tweet).mentionless.include? ":" and  meta(tweet).mentionless.partition(':').last.gsub(/\s+/, "")[0..3] == "http" and open(meta(tweet).mentionless.partition(':').last.gsub(/\s+/, "")).base_uri.to_s =~ /^http.:\/\/.*twitter.com\/parlement_ebook\/status\/[0-9]*$/
        make_answers_at_parlement(open(meta(tweet).mentionless.partition(':').last.gsub(/\s+/, "")).base_uri.to_s , tweet)
      elsif meta(tweet).mentionless.include? ":" # : in meta(tweet).mentionless
        make_a_answers(meta(tweet).mentionless.split(":")[0], tweet)
      else 
        reply(tweet, "J'ai pas compris , sorry :(")
      end
    end
  end

  def nom_compte_correct(arg)
  	if arg !~ /^[a-zA-Z0-9_]*$/
  		puts "match pas " + arg
  		return false
  	end
  	return true		
  end

  def make_answers_at_parlement(url_du_tweet, tweet)
    user = meta(tweet).mentionless.partition(":")[0].gsub(/\s+/, "")
    #on récupère le tweet qu'on auquel on doit répondre
    id_tweet = url_du_tweet.split("/")[-1]
    tweet_to_answer = twitter.status(id_tweet)
    #on charge la personne qui doit répondre
    file  = "model/" + user + ".model"
    if nom_compte_correct(user) and File.exist?(file)
      model = Ebooks::Model.load(file)
      text = "#{user} :" + model.make_response(meta(tweet_to_answer).mentionless.partition(':').last, 138 - user.length)
      opts = {}
      # on répondre au tweet auquel on doit répondre
      twitter.update(text, opts.merge(in_reply_to_status_id: tweet_to_answer.id))
    else
      reply(tweet, "Erreur sur le nom ou la formulation")
    end

  end

  def make_a_statement(user, tweet)
    user = user.gsub(/\s+/, "")
    file  = "model/" + user + ".model"
    if nom_compte_correct(user) and File.exist?(file)
      model = Ebooks::Model.load(file)
      text = "#{user} :" + model.make_statement(138 - user.length)
      tweet(text)
    else
      reply(tweet, "Erreur sur le nom ou la formulation")
    end
  end
  
  def make_a_answers(user, tweet)
    user = user.gsub(/\s+/, "")
    file  = "model/" + user + ".model"
    if nom_compte_correct(user) and File.exist?(file)
      model = Ebooks::Model.load(file)
      reply(tweet, model.make_response(meta(tweet).mentionless.partition(':').last, meta(tweet).limit + user.length - 2))
    else
      reply(tweet, "Erreur sur le nom ou la formulation")
    end
  end

end

CloneBot.new("parlement_ebook") do |bot|
  bot.access_token = "YOUR KEY HERE"
  bot.access_token_secret = "YOUR KEY HERE"

#  bot.original = "username"
end

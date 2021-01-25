require 'discordrb'
require 'yaml'
require_relative 'poe-trade.rb'

CONFIG = OpenStruct.new YAML.load_file 'settings.yaml'

bot = Discordrb::Commands::CommandBot.new  token: CONFIG.token, prefix: CONFIG.prefix
puts bot.invite_url

bot.command(:eval, help_available: false) do |event, *code|
  break unless event.user.id == CONFIG.owner
  begin
    eval code.join(' ')
  rescue => e
    "It didn't work :cry: sorry.... ```#{e}```"
  end
end


bot.command(:start, help_available: false) do |event|
  break unless event.user.id == CONFIG.owner
  running = true

  run_pc()

  poe_embed = event.send_message(nil, nil, poe_embed_create(event))

  while running == true
    sleep 10
    run_pc()
    poe_embed.edit(nil, poe_embed_create(event))
  end

end

def poe_embed_create(x)
  embed = Discordrb::Webhooks::Embed.new
  embed.tap do |e|
    e.author = { name: "PoE Prices", url: 'http://github.com/cyan101/poe-trade-discord', icon_url: x.bot.profile.avatar_url }
    e.color = '3498db'
    e.thumbnail = { url: x.bot.profile.avatar_url }
    e.title = 'PoE Map/Fragment Pricing'
    e.description = 'Information on guardian map and fragment pricing updated every 10min'
    e.timestamp = Time.now.utc
    #
    PoE_Prices.each_with_index do |(x, y), i|
      e.add_field name: x, value: y[0].to_s + 'c', inline: true
      e.add_field(name: "​​", value: "​", inline: true) if i.odd?
    end
  end
end

bot.run

require 'rubygems'
require 'sinatra'
require 'ghost'
require 'ghost/store'

BLACKLIST_IP = "127.0.0.10"
ALLOWED      = {}
HOST_THREADS = {}
HOSTS        = Ghost::Store::HostsFileStore.new

at_exit do
  ALLOWED.each_key do |host|
    thread = HOST_THREADS[host]
    thread.kill if thread
    HOSTS.add host
  end
end

# ifconfig lo0 alias 127.0.0.10

class Blacklist < Sinatra::Application

  helpers do

    def make(name)
      Ghost::Host.new name, BLACKLIST_IP
    end

    def allow_for(seconds, name)
      host = make name
      ALLOWED[host] = Time.now + seconds
      HOSTS.delete host
      Thread.new do
        sleep seconds
        add host
      end
    end

    def add(host)
      ALLOWED.delete host
      HOSTS.add host
      if thread = HOST_THREADS.delete(host)
        thread.kill
      end
    end

    def allow_link(host, label, seconds)
      %(<a href='/allow?hostname=#{host.name}&time=#{seconds}'>#{label}</a>)
    end

    def deny_button(host, label)
      %(<form class='host-deny' action='/add' method='post'>
          <input type='hidden' name='hostname' value='#{host.name}' />
          <button type='submit'>#{label}</button>
        </form>)
    end

    def time_remaining(host)
      time = ALLOWED[host]
      return "unknown" unless time
      ((time.to_i - Time.now.to_i) / 60.0).ceil.to_s
    end

  end

  get '/' do
    @blocked_hosts = HOSTS.all.select { |host| host.ip == BLACKLIST_IP }
    @allowed_hosts = ALLOWED.keys
    erb :index
  end

  post '/add' do
    if hostname = params[:hostname]
      add make(hostname)
    end
    redirect '/'
  end

  get '/allow' do
    time     = params[:time].to_i
    hostname = params[:hostname]
    allow_for time, hostname if time > 0 && hostname
    redirect '/'
  end

end
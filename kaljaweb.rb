require 'rubygems'
require 'sinatra'

get '/' do
	outlets = load_data
	erb :index, :locals => { :outlets => outlets }
end

def load_data
	Marshal.load (File.read('kaljat.data'))
end

class MarcovController < ApplicationController
  def home
    puts "PARAMS #{params}"

    unless params[:filtros].nil?
      
      
      if params[:filtros][:modelo] == "Confiabilidade"
      elsif params[:filtros][:modelo] == "Disponibilidade"
      end
    end 
  end
end
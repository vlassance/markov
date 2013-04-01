require 'matrix'

class MarcovController < ApplicationController
  def home
    puts "PARAMS #{params}"

    unless params[:filtros].nil?
      lambda = 1/(params[:filtros][:mttf].to_f)
      c = params[:filtros][:cobertura].to_f
      dt = params[:filtros][:deltat].to_f
      t = (params[:filtros][:T].to_f)*360*24

      uc = 1/(params[:filtros][:mttrc].to_f)
      uc_fault = 0
      uc_failure = 0
      if params[:filtros][:manutencao] == "Sim"
        uc_fault = uc 
      end
      if params[:filtros][:modelo] == "Confiabilidade"
        @modelo = "Conf. (R)"
      elsif params[:filtros][:modelo] == "Disponibilidade"
        uc_failure = uc
        @modelo = "Disp. (A)"
      end

      pi_zero = Matrix.row_vector([1, 0, 0])

      rows = Array.new
      rows[0] = [1-2*lambda*dt, 2*lambda*dt*c, 2*lambda*dt*(1-c)]
      rows[1] = [uc_fault*dt, 1-lambda*dt-uc_fault*dt, lambda*dt]
      rows[2] = [uc_failure*dt, 0, 1-uc_failure*dt]
      
      p = Matrix.rows(rows)

      puts "P - #{p.inspect}"

      pi_atual = pi_zero

      tempo = dt
      @string_dados = "[[0, 1]"

      if t < 1*360*24 # se o intervalo for menor que 1 ano
        intervalo_de_plotagem = 1 # dt é em horas
        puts "<1  - intervalo = #{intervalo_de_plotagem}"
      elsif t < 10*360*24 # se o intervalo for entre 1 e 10 anos
        intervalo_de_plotagem = 24 # dt é em dias
        puts "<10  - intervalo = #{intervalo_de_plotagem}"
      elsif t < 100*360*24 # se o intervalo for entre 10 e 100 anos
        intervalo_de_plotagem = 24*30 # dt é em meses
        puts "<100  - intervalo = #{intervalo_de_plotagem}"
      elsif t < 1000*360*24 # se o intervalo for entre 100 e mil anos
        intervalo_de_plotagem = 24*30*6 # dt é em semestres
        puts "<1000  - intervalo = #{intervalo_de_plotagem}"
      else # se o intervalo for maior que mil anos
        intervalo_de_plotagem = 24*30*12 # dt é em anos
        puts ">=1000 - intervalo = #{intervalo_de_plotagem}"
      end

      i = 0
      while tempo < t
        pi_atual = pi_atual * p
        @string_dados << ", [#{tempo}, #{(1 - pi_atual[3])}]" if i % intervalo_de_plotagem == 0
        tempo += dt
        i += 1
      end

      @string_dados << "]"
      puts "num. de iterações: #{i}"

    end 
  end

end

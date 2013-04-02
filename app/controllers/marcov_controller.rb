# encoding: UTF-8
require 'matrix'

class MarcovController < ApplicationController
  def home
    puts "PARAMS #{params}"

    unless params[:filtros].nil?
      epsilon = 0
      epsilon_zero = 10**-3
      epsilon_assintota = 10**-12
      lambda = 1/(params[:filtros][:mttf].to_f)
      c = params[:filtros][:cobertura].to_f
      dt = params[:filtros][:deltat].to_f
      t = (params[:filtros][:periodo].to_f)*360*24
      num_it_max = params[:filtros][:maxit].to_i

      uc = 1/params[:filtros][:mttrc].to_f
      uc_fault = 0
      uc_failure = 0
      @label_manutencao = "sem"
      if params[:filtros][:manutencao] == "Sim"
        @label_manutencao = "com"
        uc_fault = uc 
      end
      if params[:filtros][:modelo] == "Confiabilidade"
        @modelo = "Confiabilidade R(t)"
        epsilon = epsilon_zero
      elsif params[:filtros][:modelo] == "Disponibilidade"
        @modelo = "Disponibilidade A(t)"
        epsilon = epsilon_assintota
        uc_failure = uc
      end
      @titulo = "Gráfico de #{@modelo} x Tempo #{@label_manutencao} manutenção no fault (C = #{c})"
      puts "lambda: #{lambda}, c: #{c}, dt: #{dt}, t: #{t}, uc: #{uc}, uc_fault: #{uc_fault}, uc_failure: #{uc_failure}"

      pi_zero = Matrix.row_vector([1, 0, 0])

      rows = Array.new
      rows[0] = [1-2*lambda*dt, 2*lambda*dt*c, 2*lambda*dt*(1-c)]
      rows[1] = [uc_fault*dt, 1-lambda*dt-uc_fault*dt, lambda*dt]
      rows[2] = [uc_failure*dt, 0, 1-uc_failure*dt]
      
      p = Matrix.rows(rows)

      puts "P: #{p.inspect}"
      puts "pi_zero: #{pi_zero}"

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
      diff = 1
      while diff > epsilon && tempo < t && i < num_it_max
        pi_novo = pi_atual * p
        @string_dados << ", [#{tempo}, #{(1 - pi_novo[0,2])}]" if (i < 100 || i % intervalo_de_plotagem == 0)
        if params[:filtros][:modelo] == "Confiabilidade"
          diff = 1 - pi_novo[0,2]
        else # disponibilidade
          diff = (pi_novo[0,2] - pi_atual[0,2]).to_f.abs
        end
        pi_atual = pi_novo
        tempo += dt
        i += 1
      end
      puts "Valor final: #{(1 - pi_novo[0,2])}"

      @string_dados << "]"
      @numit = "Número de iterações: #{i}"
      puts "num. de iterações: #{i}"

    end 
  end

end

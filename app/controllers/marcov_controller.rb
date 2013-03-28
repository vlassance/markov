class MarcovController < ApplicationController
  def home
    puts "PARAMS #{params}"

    unless params[:filtros].nil?
      lambda = 1/(params[:filtros][:mttf].to_f)
      mi_c = 1/(params[:filtros][:mttrc].to_f)
      mi_p = 1/((params[:filtros][:mttrp].to_f)*30*24)
      fator_de_cobertura = params[:filtros][:cobetura].to_f
      delta_t = params[:filtros][:deltat].to_f
      periodo = (params[:filtros][:periodo].to_f)*360*24

      pi_zero = [1, 0, 0, 0]

      p = Array.new
      p[0] = [(1-3*lambda*delta_t), (3*lambda*delta_t*fator_de_cobertura), (3*lambda*delta_t*(1-fator_de_cobertura)), 0]
      p[1] = [(mi_c*delta_t), (1-2*lambda*delta_t-mi_c*delta_t), 0, 2*lambda*delta_t]
      p[2] = [mi_p*delta_t, 0, (1-2*lambda*delta_t-mi_p*delta_t), 2*lambda*delta_t]

      if params[:filtros][:modelo] == "Confiabilidade"
        p[3] = [0, 0, 0, 1]

        puts "P - #{p.inspect}"

        confiabilidade = Array.new
        confiabilidade[0] = 1
        pi_atual = pi_zero

        i = 1
        tempo = delta_t
        @string_dados = "["

        while tempo < periodo
          pi_atual = calcula_proximo_pi(pi_atual, p)
          confiabilidade[i] = 1 - pi_atual[3]

          @string_dados += "[#{tempo}, #{confiabilidade[i]}], "

          i += 1
          tempo += delta_t
        end

        @string_dados += "]"

        puts "CONFIBILIDADE #{confiabilidade.inspect}"
      elsif params[:filtros][:modelo] == "Disponibilidade"
        p[3] = [mi_c*delta_t, 0, 0, (1-mi_c*delta_t)]

      end
    end 
  end

  private
  def calcula_proximo_pi(pi_atual, p)
    proximo_pi = Array.new

    proximo_pi[0] = p[0][0]*pi_atual[0] + p[1][0]*pi_atual[1] + p[2][0]*pi_atual[2] + p[3][0]*pi_atual[3]
    proximo_pi[1] = p[0][1]*pi_atual[0] + p[1][1]*pi_atual[1] + p[2][1]*pi_atual[2] + p[3][1]*pi_atual[3]
    proximo_pi[2] = p[0][2]*pi_atual[0] + p[1][2]*pi_atual[1] + p[2][2]*pi_atual[2] + p[3][2]*pi_atual[3]
    proximo_pi[3] = p[0][3]*pi_atual[0] + p[1][3]*pi_atual[1] + p[2][3]*pi_atual[2] + p[3][3]*pi_atual[3]

    proximo_pi
  end
end
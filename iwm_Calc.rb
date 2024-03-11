#!ruby
#coding:utf-8

VERSION = "iwm20240310"

class Terminal
	def clear()
		print "\033[2J\033[1;1H"
	end

	def reset()
		print "\033[0m"
	end
end
Term = Terminal.new()

Signal.trap(:INT) do
	Term.reset()
	exit
end

def SubEnd()
	Term.reset()
	exit
end

HELP = <<EOD
------------------------------------------------------------
 \033[93m[Enter] ２回\033[97m        計算実行                               
 \033[93m[Space]＋[↑／↓]\033[97m   入力履歴                               
------------------------------------------------------------
 \033[96mコマンド\033[97m                                                   
   .q                終了                                   
   .r                再起動                                 
   .a                変数 一覧                              
   .da               変数 全消去                            
   .d[NUM]           変数 [NUM]を消去 d0, d1, ...           
------------------------------------------------------------
 \033[96m数式\033[97m                                                       
   pi                π = 3.141592653589793                 
   *                 3 * 2     => 6                         
   /                 3.0 / 2.0 => 1.5                       
                     3 / 2     => 1                         
   %                 3 % 2     => 1                         
   +                 3 + 2     => 5                         
   -                 3 - 2     => 1                         
   **                3 ** 2    => 9                         
   sqrt(n)           sqrt(4)   => 2.0                       
   sin(n°)          sin(30)   => 0.5                       
   cos(n°)          cos(60)   => 0.5                       
   tan(n°)          tan(45)   => 1.0                       
------------------------------------------------------------
 \033[96m例\033[97m                                                         
   > i1 = pi ↲                                              
   > i2 = 180 ↲                                             
   > .a ↲                                                   
   [0] i1 = pi ↲                                            
   [1] i2 = 180 ↲                                           
   > i1 / i2 ↲                                              
   > ↲                                                      
   i1 = Math::PI;i2 = 180;i1 / i2                           
   0.017453292519943295                                     
------------------------------------------------------------
EOD

def SubHelp()
	print "\033[97;44m Ver.#{VERSION} \n#{HELP}\033[0m"
end

def main()
	Term.clear()

	SubHelp()

	$AryVar = []
	$Exec = ""

	print "> "
	while input = STDIN.gets.strip
		case input
			when ""
				if $Exec.length > 0
						_s1 = ""
						$AryVar.each do |s|
							_s1 << s + ";"
						end
						_s1 << $Exec

						# Math::PI / 180
						_PiPerDeg = 0.017453292519943295

						# Math関係／大小文字を区別しない
						_s1.gsub!(/Math::/i, "")
						_s1.gsub!(/pi/i, "Math::PI")
						_s1.gsub!(/sqrt\(/i, "Math::sqrt(")
						_s1.gsub!(/sin\((.+?)\)/i){ "Math::sin(#{$1} * #{_PiPerDeg}).round(4)" }
						_s1.gsub!(/cos\((.+?)\)/i){ "Math::cos(#{$1} * #{_PiPerDeg}).round(4)" }
						_s1.gsub!(/tan\((.+?)\)/i){ "Math::tan(#{$1} * #{_PiPerDeg}).round(4)" }

						# 6/2(1+2)=9 と計算
						if _s1 =~ /(\d\s*\()|(\)\s*\d)/
							_s1.gsub!(/\s+/, "")
							_s1.gsub!(/(\d)\s*(\()/, "\\1*\\2")
							_s1.gsub!(/(\))\s*(\d)/, "\\1*\\2")
							_s1.gsub!(/([\+\-\*\/])/, " \\1 ")
							puts "> #{_s1}"
						end

						puts "\033[96m#{_s1}\033[93m"

					begin
						print eval(_s1).to_s
					rescue Exception => e
						puts "\033[95m#[Err] #{e.to_s.strip}"
					rescue => e
						puts "\033[95m[Err] #{e.to_s.strip}"
 					end

					Term.reset()
					puts
				end

			when ".q"
				SubEnd()
				break

			when ".r"
				main()
				break

			when ".a"
				_i1 = 0
				print "\033[96m"
				$AryVar.each do |s|
					printf("[%d] %s\n", _i1, s)
					_i1 += 1
				end
				Term.reset()
				input = ""

			when ".da"
				$AryVar = []
				input = ""

			when /\.d\d+/
				$AryVar.delete_at(input[1 .. -1].to_i)
				_i1 = 0
				$AryVar.each do |s|
					printf("[%d] %s\n", _i1, s)
					_i1 += 1
				end
				input = ""
		end

		if input.include?("=")
			$AryVar << input
			$Exec = ""
		else
			$Exec = input
		end

		print "> "
	end
end

main()

data = []
questions = nil

# read in the csv
File.open("./guys-guys-guys-no-email.csv", "r") do |f|
	lines = f.readlines

	header = lines[0].split(",")
	# manually select out the questions
	questions = header[1..7]

	lines[1..-1].each do |line|
		fields = line.split(",")
		datum = Hash[header.zip(fields)]
		data << datum
	end
end

# filter "gender neutral"/"just men" and "yes"/"no" to true/false
data.each do |datum|
	datum.each do |k, v|
		if (v == "gender neutral" || v == "Yes") then
			datum[k] = true
		elsif (v == "just men" || v == "No") then
			datum[k] = false
		end
	end
end

puts "digraph {"

# compute probabilities for all pairs of implications
questions.each do |q1|
	antecedent = q1

	antecedent_true = data.select { |datum| datum[q1] }
	antecedent_false = data.select { |datum| !datum[q1] }

	# puts "#{q1}: #{antecedent_true.count} true, #{antecedent_false.count} false"

	questions.each do |q2|
		next if q1 == q2

		consequent = q2

		at_ct = antecedent_true.select { |datum| datum[q2] }
		at_cf = antecedent_true.select { |datum| !datum[q2] }
		af_ct = antecedent_false.select { |datum| datum[q2] }
		af_cf = antecedent_false.select { |datum| !datum[q2] }

		p_a_implies_c = (at_ct.count + antecedent_false.count).to_f / data.count
		p_not_a_implies_not_c = (af_cf.count + antecedent_true.count).to_f / data.count

		guys_q1 = /\w+\sguys?/.match(q1).to_s
		guys_q2 = /\w+\sguys?/.match(q2).to_s

		if p_a_implies_c > 0.9 then
			puts "\t\"#{guys_q1}\" -> \"#{guys_q2}\" [label=\"#{p_a_implies_c.round(3)}\"];"
			# puts "#{guys_q1}->#{guys_q2}: #{p_a_implies_c} consistent"
		end

		# if p_not_a_implies_not_c > 0.9 then
		# 	puts "\t\"#{guys_q2}\" -> \"#{guys_q1}\" [label=\"neg, #{p_not_a_implies_not_c.round(3)}\"];"
		# 	# puts "!(#{guys_q1})->!(#{guys_q2}): #{p_not_a_implies_not_c} consistent"
		# end
	end
end

puts "}"

# stretch goal: filter by gender
# stretch goal: filter by location

# output
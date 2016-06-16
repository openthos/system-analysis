#encoding:utf-8

all_data = [1.1, 2.2, 3.3, 4.4, 5.5]

dvalue = Array.new
data_pre = 0
all_data.each do |data_|
abs_v = data_ - data_pre
dvalue.unshift(abs_v)

print data_pre
puts

data_pre = data_
end

p dvalue.size
p dvalue[0]
p dvalue[-1]


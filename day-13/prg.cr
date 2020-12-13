require "big"

content = File.read_lines(ARGV[0])
arrival = content[0].to_i
departures = content[1]
    .split(",")
    .map {|d| d.to_i {0}}

#puts arrival
#puts departures

shortest_wait, earliest_bus = departures
    .reject(0)
    .map {|d| {(-arrival) % d, d}}
    .min_by {|w| w[0]}
puts(shortest_wait * earliest_bus)

def extended_gcd(a, b)
    old_r, r = {a, b}
    old_s, s = {BigInt.new(1), BigInt.new(0)}
    old_t, t = {BigInt.new(0), BigInt.new(1)}

    while r != 0
        quotient = old_r // r
        old_r, r = {r, old_r - quotient * r}
        old_s, s = {s, old_s - quotient * s}
        old_t, t = {t, old_t - quotient * t}
    end

    {old_s, old_t}
end

requirements = departures
    .map_with_index {|d, i| {d, i}}
    .reject {|d, i| d == 0}
    .map{|d, i| {BigInt.new(d), BigInt.new(-i % d)}}
#puts(requirements)

repeat, earliest = requirements.reduce { |na1, na2|
    n1, a1 = na1
    n2, a2 = na2

    m1, m2 = extended_gcd(n1, n2)
    x = a1 * m2 * n2 + a2 * m1 * n1

    d = n1 * n2
    {d, x % d}
}

puts(earliest)

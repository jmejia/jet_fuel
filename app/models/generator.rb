module Generator
  def random_string
    (0...6).map{ ('a'..'z').to_a[rand(26)] }.join
  end
end

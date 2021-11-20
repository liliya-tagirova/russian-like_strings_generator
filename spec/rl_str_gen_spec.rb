require "rspec"
require_relative "../app/methods"

#russian-like_strings_generator_spec
describe "rl_str_gen" do

  # должен вернуть строку 
  it "It should return string" do
    1000.times do
      expect(rl_str_gen).to be_an_instance_of(String)
    end
  end

  # долны быть только допустимые символы
  it "It should contain only valid symbols" do
    1000.times do
      expect(rl_str_gen.match? /[^а-яё ,\.:;\-!\?\"]/i).to be false
    end
  end

  # не допускает более 300 символов
  it "It should not be ower 300 symbols" do 
    10000.times do
      expect(rl_str_gen.size).to be <= 300
    end
  end

  # от 2 до 15 слов
  it "It should contain from 2 to 15 words" do 
    1000.times do
      str = rl_str_gen
      expect(str.size).to be <= 300
      expect(str.gsub("- ", "").match? /\A *(?:[^ ]+ +){1,14}[^ ]+\z/)
      .to be(true)
    end
  end

  # не должен содержать более 15 букв
  it "It should not contains wors over 15 letters" do
    1000.times do
      words = rl_str_gen.scan(/[а-яё]+(?:-[а-яё]+)?/i)
      expect(words.count{|el| el.size > 15}).to eq(0)
    end
  end

  # откидываем последнее слово 
  # и в массиве строк берем только последний символ строки
  # запретили перед закрывающей кавычкой знаки препинания
  it "If should allow only particular marks after words within sentence" do
    1000.times do
      with_in = rl_str_gen.split.reject{|el| el == "-"}[0..-2]
      expect(with_in.reject{|el| el.match? /[а-яё]\"?[,:;]?\z/i}
        .size)
      .to eq(0)
    end
  end

  # только определенные знаки вконце предложения
  it "If should allow only particular signs in the end of the sentence" do
    1000.times do
      expect(rl_str_gen.match? /.*[а-яё]+\"?(\.|!|\?|!\?|\.\.\.)\z/)
      .to be true
    end
  end

  # не допускать нежелательные символы внутри слов 
  it "If should not allow unwanted symbols inside words" do
    1000.times do
      expect(rl_str_gen.match(/[а-яё\-][^а-яё \-]+[а-яё\-]/i)).to be_nil
    end
  end

  # не должно позволять минусы (dashes) в начале слова 
  # как работает провера если ты внутри слова, ты нашел то что непотребство, 
  # но перед ним стоит буква, если надешь такой случай - игнорируй
  it "It should exclude unwanted symbols before word's" do
    1000.times do
      expect(rl_str_gen.match(/(?<![а-яё])[^ \"а-яё]+\b[а-яё]/i)).to be_nil
    end
  end

  #Не допускается использование нескольких знаков препинания. 
  it "It should not allow multiple punctuation marks" do 
    1000.times do
      expect(rl_str_gen.match(/([^а-яё\.]) *\1/)).to be_nil
    end
  end

  # Правильное использование кавычек(четное число)
  it "It should correctly use quotation marks" do
    1000.times do 
      str = rl_str_gen
      expect( str.scan(/\"/).size.even? ).to be true
      expect( str.scan(/\".+?\"/)
        .reject { |el| el.match? /\"[а-яё].+[а-яё]\"/i }.size ).to eq(0)
    end
  end

  # Не должно допускать слов, начинающихся с 'ь ъ ы 
  it "should not allow words starting with \"ь ъ ы\"" do
    1000.times do 
      expect(rl_str_gen.match(/\b[ьъы]/i)).to be_nil
    end
  end

  # Не допускать заглавных букв после дефис и внутри слова если слово не аббревиатура
  it "It should not contain capital letters inside words if not an accronym" do
    1000.times do 
      words = rl_str_gen.gsub(/[^а-яё ]/i, "").split
      words.each do |el|
        # если нашел абривиатуру, то ничего не делать
        unless el.match? /\АА-ЯЁ{2,}\z/
          expect(el.match /\A.+[А-ЯЁ]/).to be_nil
        end
      end
    end
  end

  # Абривиатуры не должны быть не больше 5 букв
  it "It should allow accronyms only to 5 letters long" do
    1000.times do
      accr = rl_str_gen.gsub(/[^а-яё ]/i, "").scan(/А-ЯЁ{2,}/)
      expect(accr.count{ |a| a.size > 5 }).to eq(0)
    end
  end


  # Не допускать однобуквенные слова внутри предложения
  it "It should not allow one-letter words with a capital letter" do 
    1000.times do 
      expect(rl_str_gen.match(/ \"?[А-ЯЁ]\b/)).to be_nil
    end
  end
  
  # В начале слова всегда должна стоять гласная "е" или "о" после 'й'
  it "It should always have vowel after 'й' at the beginning of the word" do 
    1000.times do 
      expect(rl_str_gen.match /\b[й][^ео]/i).to be_nil
    end
  end


  # Он должен разрешать только определенные буквы после "й" внутри слов.
  it "It should allow only particular letters after 'й' inside words" do 
    1000.times do 
      expect(rl_str_gen.match /\B[й][ьъыёуаэиюжй]/i).to be_nil
    end
  end


  # В многобуквенном слове должна быть гласная.
  it "It should always be vowel in 2 and 3-letter words" do 
    1000.times do
      rl_str_gen
      .gsub(/[^а-яё ]/i, "")
      .split
      .select{ |el| el.size == 2 or el.size == 3 }
      .reject { |el| el.match?(/\A[А-ЯЁ]+\z/) }
      .each do |word|
        expect(word).to match(/[аоуэыияеёю]/i)
      end
    end
  end 


  # Он не должен допускать более 4-х согласных букв подряд
  it "It should not allow more than 4 consonant letters in a row" do 

  end

  # Он не должен допускать более 2-х гласных букв подряд
  it "It should not allow more than 2 vowel letters in a row" do 

  end


  # Он не должен допускать более двух одинаковых согласных букв подряд
  it "It should not allow more than 2 same consonant letters in a row" do 

  end 

  # Он должен содержать гласные, если не более 1 буквы и не аббревиатура. 
  it "It should contains vowels if not more than 1 letter and not an accronym" do

  end

  # Начало предложения с заглавной буквы(помнить на счет кавычек, позволять кавычку в 
  # начале строки)
  it "It should start with a capital letter" do

  end

  it "It should allow only particular one-letter words " do

  end

end

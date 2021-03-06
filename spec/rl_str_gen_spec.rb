require "rspec"
require_relative "../app/methods"
# require_relative "../app/init.rb"

#russian-like_strings_generator_spec


# вложенные методы 
describe "get_no_insert_range" do
  it "It should correctly find 4-letter consonants in a row groups" do
    1000.times do
      word  = Array.new(12) { rand(1072..1103) }
      check = word.chunk{ |el| VOWELS.any?(el) }
                  .to_a
                  .select{ |el| el[1].size > 3 && el[0] == false }
                  .map{ |el| el[1][0..3] }
      test  = get_no_insert_range(word).map{ |r| word[r][0, 4] }
      expect(test).to eq(check)
    end
  end
end



# итоговое предложение 
describe "resulting sentence" do
  before(:all) do 
    @string = rl_str_gen
  end


  # должен вернуть строку 
  it "It should return string" do
    expect(@string).to be_an_instance_of(String)
  end


  # должны быть только допустимые символы
  it "It should contain only valid symbols" do
    expect(@string.match(/[^а-яё ,\.:;\-!\?\"]/i)).to be_nil
  end


  # не допускает более 300 символов
  it "It should not be ower 300 symbols" do   
    expect(@string.size).to be <= 300 
  end


  # от 2 до 15 слов
  it "It should contain from 2 to 15 words" do 
    str = @string
    expect(str.size).to be <= 300
    expect(str.gsub("- ", "").match? /\A *(?:[^ ]+ +){1,14}[^ ]+\z/)
    .to be(true)
  end


  # не должен содержать более 15 букв
  it "It should not contains wors over 15 letters" do
    words = @string.scan(/[а-яё]+(?:-[а-яё]+)?/i)
    expect(words.count{|el| el.size > 15}).to eq(0)
  end


  # откидываем последнее слово 
  # и в массиве строк берем только последний символ строки
  # запретили перед закрывающей кавычкой знаки препинания
  it "If should allow only particular marks after words within sentence" do
    with_in = @string.split.reject{|el| el == "-"}[0..-2]
    expect(with_in.reject{|el| el.match? /[а-яё]\"?[,:;]?\z/i}
      .size)
    .to eq(0)
  end


  # только определенные знаки вконце предложения
  it "If should allow only particular signs in the end of the sentence" do
    expect(@string.match? /.*[а-яё]+\"?(\.|!|\?|!\?|\.\.\.)\z/i)
    .to be true
  end


  # не допускать нежелательные символы внутри слов 
  it "If should not allow unwanted symbols inside words" do
    expect(@string.match(/[а-яё\-][^а-яё \-]+[а-яё\-]/i)).to be_nil
  end


  # не должно позволять минусы (dashes) в начале слова 
  # как работает провера если ты внутри слова, ты нашел то что непотребство, 
  # но перед ним стоит буква, если надешь такой случай - игнорируй
  it "It should exclude unwanted symbols before word's" do
    expect(@string.match(/(?<![а-яё])[^ \"а-яё]+\b[а-яё]/i)).to be_nil
  end


  # Не допускается использование нескольких знаков препинания. 
  it "It should not allow multiple punctuation marks" do 
    expect(@string.match(/([^а-яё.]) *\1/i)).to be_nil
  end


  # Правильное использование кавычек(четное число)
  it "It should correctly use quotation marks" do
    str = @string
    expect( str.scan(/\"/).size.even? ).to be true
    expect( str.scan(/\".+?\"/)
      .reject { |el| el.match? /\"[а-яё].+[а-яё]\"/i }.size ).to eq(0)
  end


  # Не должно допускать слов, начинающихся с 'ь ъ ы 
  it "should not allow words starting with \"ь ъ ы\"" do
    expect(@string.match(/\b[ьъы]/i)).to be_nil
  end


  # Не допускать заглавных букв после дефис и внутри слова если слово не аббревиатура
  it "should not contain capital letters inside words if not an acronym" do
    words = @string.gsub(/[^а-яё ]/i, "").split
    words.each do |el|
      unless el.match?(/\A[А-ЯЁ]{2,}\z/)
        expect( el.match(/\A.+[А-ЯЁ]/) ).to be_nil
      end
    end
  end


  # Абривиатуры не должны быть не больше 5 букв
  it "It should allow accronyms only to 5 letters long" do
    accr = @string.gsub(/[^а-яё ]/i, "").scan(/А-ЯЁ{2,}/)
    expect(accr.count{ |a| a.size > 5 }).to eq(0)
  end


  # Он не должен допускать однобуквенных слов с большой буквы. 
  it "It should not allow one-letter words with a capital letter" do 
    expect(@string.match(/ \"?[А-ЯЁ]\b/)).to be_nil
  end


  # В начале слова всегда должна стоять гласная "е" или "о" после 'й'
  it "It should always have vowel after 'й' at the beginning of the word" do 
    expect(@string.match /\b[й][^ео]/i).to be_nil
  end


  # Он должен разрешать только определенные буквы после "й" внутри слов.
  it "It should allow only particular letters after 'й' inside words" do 
    expect(@string.match /\B[й][ьъыёуаэиюжй]/i).to be_nil
  end


  # В двухбуквенном и трехбуквенном слове должна быть гласная.
  it "It should always be vowel in 2 and 3-letter words" do 
    @string
    .gsub(/[^а-яё ]/i, "")
    .split
    .select{ |el| el.size == 2 or el.size == 3 }
    .reject { |el| el.match?(/\A[А-ЯЁ]+\z/) }
    .each do |word|
      expect(word).to match(/[аоуэыияеёю]/i)
    end
  end 


  # Он должен разрешать только определенные однобуквенные слова
  it "It should allow only particular one-letter words " do
    @string.scan(/\b[а-яё]\b/i)
    .each do 
      |word| expect(word).to match(/[аявоуикс]/i)
    end
  end


  # Он не должен допускать более 4-х согласных букв подряд
  it "It should not allow more than 4 consonant letters in a row" do 
    @string
    .gsub(/[^а-яё ]/i, "")
    .split
    .each do |el|
          # если нашел абривиатуру, то ничего не делать
          unless el.match? /\АА-ЯЁ{2,}\z/
            expect(el.match /\A.+[^аоуэыияеёю ]{5,}/i).to be_nil
          end
        end
      end


  #Он не должен допускать больше чем 2 гласные буквы подряд
  it "It should not allow more than 2 vowel letters in a row" do 
    @string
    .gsub(/[^а-яё ]/i, "")
    .split
    .each do |el|
          # если нашел абривиатуру, то ничего не делать
          unless el.match? /\АА-ЯЁ{2,}\z/
            expect(el.match /\A[аоуэыияеёю]{3,}/i).to be_nil
          end
        end
      end


  # Он не должен допускать более двух одинаковых согласных букв подряд
  it "It should not allow more than 2 same consonant letters in a row" do 
    @string
    .gsub(/[^а-яё ]/i, "")
    .split
    .each do |el|
        # если нашел абривиатуру, то ничего не делать
        unless el.match? /\АА-ЯЁ{2,}\z/
          expect(el.match /\A([^аоуэыияеёю])\1\1/i).to be_nil
        end
      end
    end 


  # Начало предложения с заглавной буквы(помнить на счет кавычек, 
  # позволять кавычку в начале строки)
  it "It should start with a capital letter" do
    expect(@string).to match(/\A\"?[А-ЯЁ]/)
  end


  # Он должен содержать не менее 40% гласных в многосложных словах.
  it "It should contain at least 40 persent vowels in multi-syllable words" do 

    @string.gsub(/[^а-яё ]/i, " ")
    .split
    .select { |w| w.match?(/[аоуэыияеёю].*[аоуэыияеёю]/i) }
    .each do |el|
      unless el.match?(/\А[А-ЯЁ]{2,}\z/)
        found = el.scan(/[аоуэыияеёю]/i).size 
        calc =  ( (el.size - el.scan(/[ьъ]/i).size ) * 0.4 ).to_i
        res = found >= calc ? ">=#{calc} vowels" : "#{found} vowels"
        expect([res, el])
        .to eq([">=#{calc} vowels", el])
      end
    end
  end


  # Должен содержать 5 и менее согласных в односложных словах
  it "It should contain 5 or less consonanst in single-syllable words" do 

    @string
    .gsub(/[^а-яё -]/i, "")
    .split
    .reject { |w| w.match?( /-|([аоуэыияеёю].*[аоуэыияеёю])/i ) || 
      w.match?( /\А[А-ЯЁ]{2,}\z/ ) }
      .each do |word| 
        expect( word.size ).to be <= 6
      end 
    end


  # Он должен разрешать только "я е ё ю" после "ъ ь" 
  it "It should allow only 'я е ё ю' after 'ъ' " do 
    expect(@string.gsub(/\b[А-ЯЁ]{2,}\b/, "")
      .match(/ъ[^яеёю]/i)).to be_nil
  end


  # В односложных словах не должно быть гласных в начале слова, 
  # если они состоят из 3 или более букв.
  it "It should not allow a vowel at begining of the word" \
  "in single-syllable word's if they have 3 or more letters" do
    @string.gsub(/[^а-яё -]/i, "")
    .split
    .reject { |w| w.match?(/\-|([аоуэыияеёю].*[аоуэыияеёю])/i) ||
      w.match?(/\A[А-ЯЁ]{2,}\z/) || 
      w.size < 3 }
      .each do |word| 
        expect( word ).to match(/\A[^аоуэыияеёю]/i)
      end
    end


  # Следует запретить "Ь Ъ" в акронимах. 
  it "It should forbid 'Ь Ъ' in acronyms" do
    expect(@string.match(/(?=\b[А-ЯЁ]{2,}\b)\b[А-ЯЁ]*[ЪЬ][А-ЯЁ]*\b/)).to be_nil
  end
end

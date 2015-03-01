class Voice
  def low(phrase)
    if RUNNING_ON_PI
      `espeak "#{phrase}" -a 500 -s 140`
    else
      `say -v Alex "#{phrase}"`
    end
  end

  def high(phrase)
    if RUNNING_ON_PI
      `espeak "#{phrase}" -a 500 -s 140 -p 200`
    else
      `say -v Vicki "#{phrase}"`
    end
  end
end

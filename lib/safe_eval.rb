require 'timeout'

DEFAULT_SAFE_LEVEL = 0 unless defined?(DEFAULT_SAFE_LEVEL)
def eval_safe_level
  $eval_safe_level || DEFAULT_SAFE_LEVEL
end

class SafeEval
  def self.with_level(level)
    old = $eval_safe_level
    $eval_safe_level = level
    yield
  ensure
    $eval_safe_level = old
  end
end

def safe_eval_fork(str,ops)
  fork do
    new_str = "$SAFE=#{eval_safe_level}; #{str}"
    $res = res = eval(new_str)
    puts "RES: #{res}"
  end
  Process.wait
end

def safe_eval_thread(str,ops={})
  res = nil
  level = ops[:safe] || eval_safe_level
  Thread.new do
    new_str = "$SAFE=#{level}; #{str}"
    res = eval(new_str)
    #puts "RES: #{res}"
  end.join
  res
end

class EvalError < SecurityError
end

def safe_eval(str,ops={})
  if true
    res = nil
    seconds = ops[:timeout] || 5
    Timeout::timeout(seconds) { res = safe_eval_thread(str,ops) }
    #puts "Thread return: #{res}"
    res
  else
    safe_eval_fork(str,ops)
  end
rescue(SecurityError) => exp
  exp = exp.exception("Eval code \"#{str}\"\n#{exp.message}")
  raise exp
end

def bt
  raise 'foo'
rescue => exp
  return exp.backtrace.join("\n")
end

class Object
  attr_accessor :stored_exception
  def safe_instance_eval(str,ops={})
    res = nil
    level = ops[:safe] || eval_safe_level
    debug_log "going to eval #{str} at level #{level} against #{inspect}"
    Thread.new do
      $SAFE = level if level > $SAFE
      #new_str = "begin; #{str}; rescue(Exception) => e; raise e.exception(bt+e.message); end"
      res = instance_eval(str)
    end.join
    res
  rescue(SecurityError) => exp
    exp = exp.exception("Eval code \"#{str}\"\n#{exp.message}")
    raise exp
  end
end

class Object
  def app_instance_eval(str,ops={})
    TT.log("app_instance_eval #{str}") do
      #if str =~ /children\(:picks\).parent\(:players\)/
      #  4
      #else
        safe_instance_eval(unescape(str),ops)
      #end
      #instance_eval(unescape(str))
    end
  end
end
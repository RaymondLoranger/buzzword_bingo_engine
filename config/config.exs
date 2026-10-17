import Config

# import_config "config_logger.exs"

# Supervisor Behaviour tracks restart frequency for its child processes:

# • If a child process crashes and is restarted more than :max_restarts times
#   within the window of :max_seconds, the supervisor gives up.

# • When this threshold is exceeded, the supervisor terminates all of its
#   remaining child processes and then crashes/exits itself.

# • The crash then escalates up the supervision tree to the parent supervisor,
#   which will attempt to handle or restart that supervisor according to its own
#   strategy.

# Supervisor option defaults for :max_restarts and :max_seconds...
{max_restarts, max_seconds} = {3, 5}
# 1.6666666666666667 sec...
min_seconds_between_restarts = max_seconds / max_restarts
# 1,667 ms...
between_restarts = round(min_seconds_between_restarts * 1_000)

# 1,667 - 1,534 = 133 ms...
between_server_kills = between_restarts - 1_534
# 1,667 - 668 = 999 ms...
between_dyn_sup_kills = between_restarts - 668
# 1,667 + 221 = 1,888 ms...
between_sup_kills = between_restarts + 221
between_registration_checks = 10

# from = "➔ from #{Path.relative_to_cwd(__ENV__.file)}..."
# env = config_env()
# IO.puts("(#{env}) Between server kills: #{between_server_kills} ms #{from}")
# IO.puts("(#{env}) Between dyn sup kills: #{between_dyn_sup_kills} ms #{from}")
# IO.puts("(#{env}) Between sup kills: #{between_sup_kills} ms #{from}")

config :buzzword_bingo_engine,
  between_server_kills: between_server_kills,
  between_dyn_sup_kills: between_dyn_sup_kills,
  between_sup_kills: between_sup_kills,
  between_registration_checks: between_registration_checks

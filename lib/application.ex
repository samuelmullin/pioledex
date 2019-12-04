defmodule PIOLEDex.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      Supervisor.child_spec(PIOLEDex.Screen, id: :pioledex),

    ]

    opts = [strategy: :one_for_one, name: PIOLEDex.Supervisor]
    Supervisor.start_link(children, opts)
  end

end

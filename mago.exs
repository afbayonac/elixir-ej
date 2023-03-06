defmodule Mago do
  def doors do
    [
      "X", "X", "X", "◉", "◉", "◉", "◉", "$50", "$100", "$200"
    ]
    |> Enum.shuffle()
  end

  def loop(game) when game.ronda <= 6 and game.x < 3 and game.tyres < 4 do
    game
    |> select()
    |> open()
    |> count()
    |> ronda()
    |> loop()
  end

  def loop(game) do
    if game.tyres === 4 do
      "\nYou have a car new 🚗\n" |> IO.puts
    end

    if game.money > 0 do
      "\nYou have $#{game.money}\n" |> IO.puts
    end

    if game.x === 3 or (game.money === 0 and game.tyres < 4) do
      "\nYou lost\n" |> IO.puts
    end

    game
  end

  def car(game) when game.money <= 0 do
    game |> IO.inspect()
  end


  def ronda(game) do
    case game.box do
      "X" -> "\nEmpy Door\n"
      "◉" -> "\nA tire ◉\n"
      "" -> "\nYou've missed your turn\n"
      m -> "\nYou have won #{m}\n"
    end
    |> IO.puts


    "tyres: #{game.tyres}" |> IO.puts
    "money: $#{game.money} \n" |> IO.puts

    game
    |> Map.merge(%{ ronda: game.ronda + 1 })
  end

  def select(game) do
    "### #{game.ronda} ###\n\t" |> IO.puts

    game.opened
    |> Enum.join(" | ")
    |> IO.puts

    door = IO.gets("Select the next door: ") |> String.trim() |> String.upcase
    regex = ~r/^P([0-9]|10)$/

    door = cond do
      door |> String.match?(regex) -> door_to_number(door)
      true -> select(game)
    end

    game
    |> Map.merge(%{
      select: door
    })
  end

  def door_to_number(door) do
    n = door |> String.replace("P", "") |> String.to_integer()
    n - 1
  end

  def open(game) do
    box = game.doors |> Enum.at(game.select)

    case box do
      "" -> game
      |> Map.merge(%{
        box: box
      })
      _ -> game
      |> Map.merge(%{
        opened: game.opened |> List.replace_at(game.select, box),
        doors: game.doors |> List.replace_at(game.select, ""),
        box: box
      })
    end
  end

  def count(game) do

    map = case game.box do
      "X" -> %{ x: game.x + 1 }
      "◉" -> %{ tyres: game.tyres + 1 }
      "" -> %{}
      m -> %{ money: game.money + (m |> String.replace("$", "") |> String.to_integer) }
    end

    game
    |> Map.merge(map)
  end

  def init do
    %{
      doors: doors() |> IO.inspect(),
      opened:  Enum.map(1..10, fn v -> "P#{v}" end),
      select: 0,
      money: 0,
      tyres: 0,
      x: 0,
      ronda: 1,
      box: nil
    }
    |> loop
  end
end

Mago.init()

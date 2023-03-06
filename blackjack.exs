defmodule Blackjack do
  def maze do
    [
      "A♣", "2♣", "3♣", "4♣", "5♣", "6♣", "7♣", "8♣", "9♣", "10♣", "J♣", "Q♣", "K♣",
      "A♦", "2♦", "3♦", "4♦", "5♦", "6♦", "7♦", "8♦", "9♦", "10♦", "J♦", "Q♦", "K♦",
      "A♥", "2♥", "3♥", "4♥", "5♥", "6♥", "7♥", "8♥", "9♥", "10♥", "J♥", "Q♥", "K♥",
      "A♠", "2♠", "3♠", "4♠", "5♠", "6♠", "7♠", "8♠", "9♠", "10♠", "J♠", "Q♠", "K♠"
    ]
    |> Enum.shuffle()
  end

  def play(game) when game.continue do
    game
    |> stil()
    |> ronda()
    |> continue()
    |> play()
  end

  def play(game) do
    game
    |> status()
    |> IO.inspect()
  end

  def status(game) do
    case {game.user.points, game.cpu.points} do
      {u, c} when c === u -> "Tie"
      {21, _} -> "User is the winner"
      {_, 21} -> "CPU is the winner"
      {u, c} when u > 21 and c < 21 -> "User is the loser"
      {u, c} when u < 21 and c > 21-> "CPU is the loser"
      {u, c} when u > 21 and c > 21 and u < c -> "User is the winner"
      {u, c} when u > 21 and c > 21 and u > c -> "CPU is the winner"
      {u, c} when u > c -> "User is the winner"
      {u, c} when c > u -> "CPU is the winner"
    end
  end

  def stil(game) do
    [first | [second | tail]] = game.maze

    game
    |> Map.merge(%{
      maze: tail,
      user: game.user.cards |> add_card(first),
      cpu: game.cpu.cards |> add_card(second)
    })
  end

  def add_card(cards, card) do
    new_cards = cards ++ [card]
    as = new_cards |> Enum.count(fn x -> x |> String.first === "A" end)
    %{
      cards: new_cards,
      points: count(new_cards) |> as_behaviour(as)
    }
  end

  def count([], sum), do: sum
  def count([card | tail], sum), do: count(tail, sum + value(card))

  def as_behaviour(points, 0), do: points
  def as_behaviour(points, _) when points <= 21, do: points
  def as_behaviour(points, as), do: as_behaviour(points - 10, as - 1)

  def value(card) do
    case card |> String.slice(0..-2) do
      "A" -> 11
      "J" -> 10
      "K" -> 10
      "Q" -> 10
      a  -> a |> String.to_integer()
    end
  end

  def ronda(game) do
    "\n" |> IO.puts
    "¡¡¡ Ronda: #{game.ronda} !!!" |> IO.puts
    "User: #{game.user.cards |> Enum.join(" ")}" |> IO.puts
    "CPU:  #{game.cpu.cards |> Enum.join(" ")} \n" |> IO.puts

    game
    |> Map.merge(%{ ronda: game.ronda + 1 })
  end

  def continue(game) do
    str = "Do you steal? [Y / N]  "
    game
    |> Map.merge(%{
        continue: game.user.points < 21
          &&  game.cpu.points < 21
          && IO.gets(str) |> String.first() === "Y"
      })
  end

  def init do
    %{
      maze: maze(),
      user: %{
        cards: [],
        points: 0
      },
      cpu: %{
        cards: [],
        points: 0
      },
      ronda: 1,
      continue: true
    }
    |> play
  end
end

IO.puts("♣ ♦ ♥ ♠")
Blackjack.init()

# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs

alias Livekwest.Repo
alias Livekwest.Accounts.User
alias Livekwest.Quizzes.{Quiz, Question}

{:ok, alice} = %User{}
|> User.changeset(%{
  email: "user@domain.tld",
  name: "alice",
  password: "supercomplexpassword"
})
|> Repo.insert()

{:ok, bob} = %User{}
|> User.changeset(%{
  email: "bob@domain.tld",
  name: "bob",
  password: "supercomplexpassword"
})
|> Repo.insert()

{:ok, quiz_1} = %Quiz{
  title: "Music Through the Decades",
  user_id: alice.id
} |> Repo.insert()

music_questions = [
  %{content: "How many Sonnets are in Vivaldi's Four Season", index: 0},
  %{content: "Which band released 'Dark Side of the Moon' in 1973?", index: 1},
  %{content: "Who was known as the 'King of Pop'?", index: 2},
  %{content: "Which Swedish pop group won Eurovision in 1974 with 'Waterloo'?", index: 3},
  %{content: "Name the four members of The Beatles.", index: 4},
  %{content: "Which rock band was originally called 'The New Yardbirds'?", index: 5},
  %{content: "Who wrote and first performed 'Nothing Compares 2 U', later made famous by Sinéad O'Connor?", index: 6},
  %{content: "Which famous guitarist had a custom guitar called 'Black Beauty'?", index: 7}
]

Enum.each(music_questions, fn question ->
  %Question{
    quiz_id: quiz_1.id,
    type: :open,
    content: question.content,
    index: question.index
  } |> Repo.insert!()
end)

{:ok, quiz_2} = %Quiz{
  title: "Basic Science",
  user_id: bob.id
} |> Repo.insert()

quiz_2_questions = [
  %{content: "What is heavier, a kilo of steel or a kilo of feathers", index: 0},
  %{content: "What is the only mammal that can't jump?", index: 1},
  %{content: "In which country would you find the original Leaning Tower?", index: 2},
  %{content: "What color is a giraffe's tongue?", index: 3},
  %{content: "How many hearts does an octopus have?", index: 4},
  %{content: "Which planet in our solar system has the most moons?", index: 5},
  %{content: "What is the name of the phobia that means fear of long words?", index: 6},
  %{content: "In what year did the Titanic sink?", index: 7},
  %{content: "What is the smallest country in the world?", index: 8}
]

Enum.each(quiz_2_questions, fn question ->
  %Question{
    quiz_id: quiz_2.id,
    type: :open,
    content: question.content,
    index: question.index
  } |> Repo.insert!()
end)

{:ok, quiz_3} = %Quiz{
  title: "World History",
  user_id: bob.id
} |> Repo.insert()

history_questions = [
  %{content: "Who was the first man to set foot on the moon?", index: 0},
  %{content: "What was the main event that started World War I?", index: 1},
  %{content: "Who was America's first billionaire?", index: 2},
  %{content: "Who was Leonardo da Vinci and what were his contributions?", index: 3},
  %{content: "What was the first live-stream video on the internet?", index: 4},
  %{content: "What was Che Guevara's real first name?", index: 5},
  %{content: "What countries were involved in the Wars of the Three Kingdoms?", index: 6},
  %{content: "In what year did the Ottomans conquer Constantinople?", index: 7}
]

Enum.each(history_questions, fn question ->
  %Question{
    quiz_id: quiz_3.id,
    type: :open,
    content: question.content,
    index: question.index
  } |> Repo.insert!()
end)

IO.puts "Seed data inserted successfully!"

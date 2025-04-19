defmodule Livekwest.QuizManager do
  use GenServer

  import Livekwest.Utils, only: [topic: 1]

  #######
  # API #
  #######

  def start_link(_), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  def init(state), do: {:ok, state}

  def init_quiz(code, questions) do
    questions_with_ids =
      Enum.with_index(questions)
      |> Enum.map(fn {text, index} ->
        %{
          id: generate_id(),
          text: text,
          index: index
        }
      end)

    GenServer.cast(__MODULE__, {:init_quiz, code, questions_with_ids})
  end

  def get_quiz(code), do: GenServer.call(__MODULE__, {:get_quiz, code})

  def get_questions(code), do: GenServer.call(__MODULE__, {:get_questions, code})

  def get_active_question(code), do: GenServer.call(__MODULE__, {:get_active_question, code})

  def set_active_question(code, index),
    do: GenServer.cast(__MODULE__, {:set_active_question, code, index})

  def start_quiz(code), do: GenServer.cast(__MODULE__, {:start_quiz, code})

  def add_participant(code, participant) do
    with id <- generate_id(),
         updated_participant <- Map.put(participant, :id, id),
         :ok <- GenServer.cast(__MODULE__, {:add_participant, code, updated_participant}) do
      {:ok, id}
    end
  end

  @spec remove_participant(string(), string()) :: :ok
  def remove_participant(code, id),
    do: GenServer.cast(__MODULE__, {:remove_participant, code, id})

  def get_participants(code), do: GenServer.call(__MODULE__, {:get_participants, code})

  #################
  # GENERAL CALLS #
  #################

  def handle_call({:get_quiz, code}, _from, state) do
    {:reply, Map.get(state, code), state}
  end

  ###################
  # QUESTIONS CALLS #
  ###################

  def handle_call({:get_questions, code}, _from, state) do
    questions = get_in(state, [code, :questions]) || []
    {:reply, questions, state}
  end

  def handle_call({:get_active_question, code}, _from, state) do
    with %{questions: questions, active_index: i} <- Map.get(state, code),
         question <- Enum.at(questions, i) do
      {:reply, question, state}
    else
      _ -> {:reply, nil, state}
    end
  end

  ######################
  # PARTICIPANTS CALLS #
  ######################

  def handle_call({:get_participants, code}, _from, state) do
    participants = get_in(state, [code, :participants]) || []
    {:reply, participants, state}
  end

  #################
  # GENERAL CASTS #
  #################

  def handle_cast({:init_quiz, code, questions}, state) do
    quiz = %{
      started?: false,
      questions: questions,
      active_index: 0,
      participants: []
    }

    {:noreply, Map.put(state, code, quiz)}
  end

  def handle_cast({:start_quiz, code}, state) do
    # update started flag
    quiz = Map.get(state, code) |> Map.put(:started?, true)
    IO.inspect(quiz)

    topic = topic(code)
    Phoenix.PubSub.broadcast(Livekwest.PubSub, topic, :quiz_started)

    {:noreply, Map.put(state, code, quiz)}
  end

  ###################
  # QUESTIONS CASTS #
  ###################

  def handle_cast({:set_active_question, code, index}, state) do
    quiz = Map.get(state, code)

    if quiz do
      updated_quiz = Map.put(quiz, :active_index, index)
      question = Enum.at(updated_quiz.questions, index)
      new_state = Map.put(state, code, updated_quiz)

      topic = topic(code)
      Phoenix.PubSub.broadcast(Livekwest.PubSub, topic, {:active_question_changed, question})

      {:noreply, new_state}
    else
      {:noreply, state}
    end
  end

  ######################
  # PARTICIPANTS CASTS #
  ######################

  def handle_cast({:add_participant, code, participant}, state) do
    quiz = Map.get(state, code, %{})

    participants =
      quiz
      |> Map.get(:participants, [])
      |> then(fn existing_participants -> existing_participants ++ [participant] end)
      |> Enum.uniq()

    updated_quiz =
      quiz
      |> Map.put(:participants, participants)

    new_state = Map.put(state, code, updated_quiz)

    topic = topic(code)
    Phoenix.PubSub.broadcast(Livekwest.PubSub, topic, {:new_participant, participant})
    Phoenix.PubSub.broadcast(Livekwest.PubSub, topic, :participants_updated)

    {:noreply, new_state}
  end

  def handle_cast({:remove_participant, code, id}, state) do
    quiz = Map.get(state, code, %{})

    updated_quiz =
      quiz
      |> Map.get(:participants, [])
      |> Enum.reject(fn p -> p.id == id end)
      |> then(&Map.put(quiz, :participants, &1))

    new_state = Map.put(state, code, updated_quiz)

    topic = topic(code)
    Phoenix.PubSub.broadcast(Livekwest.PubSub, topic, {:removed_participant, id})
    Phoenix.PubSub.broadcast(Livekwest.PubSub, topic, :participants_updated)

    {:noreply, new_state}
  end

  defp generate_id(), do: :crypto.strong_rand_bytes(6) |> Base.url_encode64(padding: false)
end

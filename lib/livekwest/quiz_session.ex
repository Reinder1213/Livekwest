defmodule Livekwest.QuizSession do
  use GenServer

  require Logger

  import Livekwest.Utils, only: [topic: 1]

  #######
  # API #
  #######

  @spec start_link(any()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(code) when is_binary(code) do
    GenServer.start_link(__MODULE__, %{code: code}, name: via_tuple(code))
  end

  def init(%{code: code}) do
    {:ok,
     %{
       code: code,
       started: false,
       questions: [],
       participants: [],
       answers: %{},
       active_index: 0
     }}
  end

  def init_quiz(code, questions) do
    GenServer.cast(via_tuple(code), {:init_quiz, questions})
  end

  def get_quiz(code), do: GenServer.call(via_tuple(code), {:get_quiz, code})

  def get_questions(code), do: GenServer.call(via_tuple(code), :get_questions)

  def get_active_question(code), do: GenServer.call(via_tuple(code), :get_active_question)

  def set_active_question(code, index),
    do: GenServer.cast(via_tuple(code), {:set_active_question, code, index})

  def start_quiz(code), do: GenServer.cast(via_tuple(code), {:start_quiz, code})

  def add_participant(code, participant) do
    with id <- generate_id(),
         updated_participant <- Map.put(participant, :id, id),
         :ok <- GenServer.cast(via_tuple(code), {:add_participant, code, updated_participant}) do
      {:ok, id}
    end
  end

  def remove_participant(code, id),
    do: GenServer.cast(via_tuple(code), {:remove_participant, code, id})

  def get_participants(code), do: GenServer.call(via_tuple(code), :get_participants)

  def submit_answer(code, question_id, participant_id, value),
    do:
      GenServer.cast(via_tuple(code), {:submit_answer, code, question_id, participant_id, value})

  #################
  # GENERAL CALLS #
  #################

  def handle_call({:get_quiz, code}, _from, state) do
    {:reply, Map.get(state, code), state}
  end

  ###################
  # QUESTIONS CALLS #
  ###################

  def handle_call(:get_questions, _from, state) do
    {:reply, state.questions, state}
  end

  def handle_call(:get_active_question, _from, state) do
    with %{questions: questions, active_index: i} <- state,
         question <- Enum.at(questions, i) do
      {:reply, question, state}
    else
      _ -> {:reply, nil, state}
    end
  end

  ######################
  # PARTICIPANTS CALLS #
  ######################

  def handle_call(:get_participants, _from, state) do
    {:reply, state.participants, state}
  end

  #################
  # GENERAL CASTS #
  #################

  def handle_cast({:init_quiz, questions}, state) do
    new_state = %{state | questions: questions, started: false, active_index: 0}
    {:noreply, new_state}
  end

  def handle_cast({:start_quiz, code}, state) do
    topic = topic(code)
    Phoenix.PubSub.broadcast(Livekwest.PubSub, topic, :quiz_started)

    {:noreply, Map.put(state, :started, true)}
  end

  ###################
  # QUESTIONS CASTS #
  ###################

  def handle_cast({:set_active_question, code, index}, state) do
    updated_quiz = Map.put(state, :active_index, index)
    question = Enum.at(updated_quiz.questions, index)

    topic = topic(code)
    Phoenix.PubSub.broadcast(Livekwest.PubSub, topic, {:active_question_changed, question})

    {:noreply, updated_quiz}
  end

  ######################
  # PARTICIPANTS CASTS #
  ######################

  def handle_cast({:add_participant, code, participant}, state) do
    participants =
      state
      |> Map.get(:participants, [])
      |> then(fn existing_participants -> existing_participants ++ [participant] end)
      |> Enum.uniq()

    topic = topic(code)
    Phoenix.PubSub.broadcast(Livekwest.PubSub, topic, {:new_participant, participant})
    Phoenix.PubSub.broadcast(Livekwest.PubSub, topic, :participants_updated)

    {:noreply, Map.put(state, :participants, participants)}
  end

  def handle_cast({:remove_participant, code, id}, state) do
    new_state =
      state
      |> Map.get(:participants, [])
      |> Enum.reject(fn p -> p.id == id end)
      |> then(&Map.put(state, :participants, &1))

    topic = topic(code)
    Phoenix.PubSub.broadcast(Livekwest.PubSub, topic, {:removed_participant, id})
    Phoenix.PubSub.broadcast(Livekwest.PubSub, topic, :participants_updated)

    {:noreply, new_state}
  end

  ################
  # ANSWER CASTS #
  ################

  # hurray for singlethreaded processes
  # todo handle non existing question or participant IDs
  def handle_cast({:submit_answer, code, q_id, p_id, value}, state) do
    new_state =
      state.questions
      |> Enum.map(fn q ->
        if q.id == q_id, do: update_answers(q, p_id, value), else: q
      end)
      |> then(&Map.put(state, :questions, &1))

    topic = topic(code)
    Phoenix.PubSub.broadcast(Livekwest.PubSub, topic, {:answer_submitted, q_id, p_id})

    {:noreply, new_state}
  end

  defp update_answers(%{answers: answers} = question, pid, value) when is_map(answers),
    do: answers |> Map.put(pid, value) |> then(&Map.put(question, :answers, &1))

  defp update_answers(question, pid, value), do: question |> Map.put(:answers, %{pid => value})

  defp generate_id(), do: :crypto.strong_rand_bytes(6) |> Base.url_encode64(padding: false)

  defp via_tuple(code), do: {:via, Registry, {Livekwest.QuizRegistry, code}}
end

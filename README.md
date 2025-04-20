# LiveKwest — Real-time pub quiz in Phoenix LiveView

A simple tool to help out with your local fun pubquiz. In a Jackbox Games-like way people can join the fun and answer question. A nice presentation mode is there to be projected on a screen.
Questions and answers are send back and forth in realtime.

To start the project:

- Run `docker-compose up --build` in the root
- Run migration and seeds (when postgres is up) `docker compose run --rm app mix ecto.setup`
- Or re-run migration and seeds (when postgres is up) `docker compose run --rm app mix ecto.reset`, as databse is not cleared on setup

Project is available at [`localhost:4000`](http://localhost:4000).

## Features

- State of a quiz is managed in a QuizManager GenServer. It holds quiz state in memory.
- A quiz is initialized from `ControlLive` by quizmaster.
- LiveViews subscribe to quiz:<code> topics via Phoenix PubSub.
- Broadcasts keep everyone in sync (presentation screen, control screen, join screen).
- Participants have a generated id and are tracked per quiz. No need to signin for a spontanous quiz session.
- Questions and answers are stored in memory for now.

## Todo

- [ ] Improve state managment with a GenServer per quiz
- [ ] Scoring
- [ ] Managing Quizzes

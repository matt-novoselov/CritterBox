# PokemonBox

This project demonstrates basic usage of PokéAPI.

The `PokemonService` uses `URLSession` with Swift's async/await to download a
list of Pokémon and returns their main details:

- `name`
- `flavorText`
- `eggGroups`
- `types`
- `shinyArtworkURL`

When the app launches, the main view controller fetches a small set of Pokémon
using `PokemonService` and prints the results with `dump`.

See [PokéAPI documentation](https://pokeapi.co/docs/v2) for the REST API
endpoints.

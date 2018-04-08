# Procedular World Map Generator

A simple ruby app that generates procedular world maps. The maps can be randomly generated or can be deterministic if a numerical seed is provided.

The map has a biome associated to moisture and elevation for each coordinate, and this is powered by multiple perlin noise layers. It generates an colored ascii and png version of the map. 

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

You need ruby and bundler installed. You'll need to git clone this repository to your local machine. Aftewards cd into the directory.


### Installation

Simply install the gems and run the 'rake start' task:

```
bundle install
rake start
```
## Authors

* **Andres** - [Mindware](https://github.com/mindware)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Hat tip to Shawn Anderson, Junegunn Choi, Willem van Bergen


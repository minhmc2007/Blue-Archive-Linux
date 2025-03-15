# Define an array of greetings
set greetings "Welcome, Sensei!" "Good to see you, Sensei!" "Ready to hack, Sensei?" "Stay sharp, Sensei!" "Another great day, Sensei!" "Time to code, Sensei!"

# Pick a random greeting
set rand_index (math (random) % (count $greetings) + 1)
echo -e "\n\033[1;36m$greetings[$rand_index]\033[0m\n"

<template>
  <Modal
    v-if="modals.reminder && availableReminders.length && players[playerIndex]"
    @close="toggleModal('reminder')"
  >
    <h3>Choisissez un jeton de rappel :</h3>
    <ul class="reminders">
      <li
        v-for="reminder in availableReminders"
        class="reminder"
        :class="[reminder.role]"
        :key="reminder.role + ' ' + reminder.name"
        @click="addReminder(reminder)"
      >
        <div class="icon-wrapper">
          <span
            class="icon"
            :style="{
              backgroundImage: `url(${
                reminder.image && grimoire.isImageOptIn
                  ? reminder.image
                  : require('../../assets/icons/' +
                      (reminder.imageAlt || reminder.role) +
                      '.png')
              })`
            }"
          ></span>
        </div>
        <span class="text">{{ reminder.name }}</span>
      </li>
    </ul>
  </Modal>
</template>

<script>
import Modal from "./Modal";
import { mapMutations, mapState } from "vuex";

/**
 * Helper function that maps a reminder name with a role-based object that provides necessary visual data.
 * @param role The role for which the reminder should be generated
 * @return {function(*): {image: string|string[]|string|*, role: *, name: *, imageAlt: string|*}}
 */
const mapReminder = ({ id, image, imageAlt }) => name => ({
  role: id,
  image,
  imageAlt,
  name
});

export default {
  components: { Modal },
  props: ["playerIndex"],
  computed: {
    availableReminders() {
      let reminders = [];
      const { players, bluffs } = this.$store.state.players;
      this.$store.state.roles.forEach(role => {
        // add reminders from player roles
        if (players.some(p => p.role.id === role.id)) {
          reminders = [...reminders, ...role.reminders.map(mapReminder(role))];
        }
        // add reminders from bluff/other roles
        else if (bluffs.some(bluff => bluff.id === role.id)) {
          reminders = [...reminders, ...role.reminders.map(mapReminder(role))];
        }
        // add global reminders
        if (role.remindersGlobal && role.remindersGlobal.length) {
          reminders = [
            ...reminders,
            ...role.remindersGlobal.map(mapReminder(role))
          ];
        }
      });
      // add fabled reminders
      this.$store.state.players.fabled.forEach(role => {
        reminders = [...reminders, ...role.reminders.map(mapReminder(role))];
      });

      // add out of script traveler reminders
      this.$store.state.otherTravelers.forEach(role => {
        if (players.some(p => p.role.id === role.id)) {
          reminders = [...reminders, ...role.reminders.map(mapReminder(role))];
        }
      });

      reminders.push({ role: "good", name: "Good" });
      reminders.push({ role: "evil", name: "Evil" });
      reminders.push({ role: "custom", name: "Custom note" });
      return reminders;
    },
    ...mapState(["modals", "grimoire"]),
    ...mapState("players", ["players"])
  },
  methods: {
    addReminder(reminder) {
      const player = this.$store.state.players.players[this.playerIndex];
      let value;
      if (reminder.role === "custom") {
        const name = prompt("Ajoutez un jeton de rappel personnalisé");
        if (!name) return;
        value = [...player.reminders, { role: "custom", name }];
      } else {
        value = [...player.reminders, reminder];
      }
      this.$store.commit("players/update", {
        player,
        property: "reminders",
        value
      });
      this.$store.commit("toggleModal", "reminder");
    },
    ...mapMutations(["toggleModal"])
  }
};
</script>

<style scoped lang="scss">
ul.reminders .reminder {
  background-color: #f8e1c2;
  border: 7px solid #e0b35e;
  background-size: 100%;
  width: 14vh;
  height: 14vh;
  max-width: 100px;
  max-height: 100px;
  display: flex;
  justify-content: center;
  align-items: center;
  margin: 1%;

  border-radius: 50%;
  box-shadow: 0 0 10px rgba(0, 0, 0, 0.5);
  cursor: pointer;
  line-height: 100%;
  transition: transform 500ms ease;

  .icon-wrapper {
    overflow: hidden;
    position: absolute;
    top: 5%;
    width: 55%;
    height: 55%;
    
    .icon {
      position: absolute;
      top: 0;
      width: 100%;
      height: 100%;
      background-size: 100%;
      background-position: center center;
      background-repeat: no-repeat;
    }
  }


  .text {
    color: black;
    font-size: .65rem;
    font-weight: bold;
    text-align: center;
    top: 15%;
    width: 80%;
    line-height: 1;
  }

  &:hover {
    transform: scale(1.2);
  }
}
</style>

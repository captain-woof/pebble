import { RouteRecordRaw } from "vue-router";
import HomePage from "@components/pages/home/index.vue";
import ContactsPage from "@components/pages/contacts/index.vue";
import GroupChatPage from "@components/pages/group-chat/index.vue";

export const routes: Array<RouteRecordRaw> = [
    // Homepage
    {
        name: "home",
        component: HomePage,
        path: "/"
    },

    // Contacts
    {
        name: "contacts",
        component: ContactsPage,
        path: "/contacts"
    },

    // Group chat
    {
        name: "group-chat",
        component: GroupChatPage,
        path: "/group-chat/:groupId"
    },
];
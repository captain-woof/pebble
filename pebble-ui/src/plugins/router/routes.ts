import { RouteRecordRaw } from "vue-router";
import HomePage from "@components/pages/home/index.vue";
import GroupsPage from "@components/pages/groups/index.vue";
import GroupChatPage from "@components/pages/group-chat/index.vue";

export const routes: Array<RouteRecordRaw> = [
    // Homepage
    {
        name: "home",
        component: HomePage,
        path: "/"
    },

    // Groups
    {
        name: "groups",
        component: GroupsPage,
        path: "/groups"
    },

    // Group chat
    {
        name: "group-chat",
        component: GroupChatPage,
        path: "/group-chat/:groupId"
    },
];
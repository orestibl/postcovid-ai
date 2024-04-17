import { Filter } from "@/types/types";
import { useQuery } from "react-query";

const fetchUsers = async (study: string) => {
  if (!study) return [];

  const path = `/postcovid-dashboard/api/user/study/${study}`;

  const response = await fetch(path);
  if (!response.ok) {
    console.error("Error fetching users", response);
    throw new Error("Network response was not ok");
  }
  const users = await response.json();

  return users;
};

export const useUsers = (study: string) => {
  return useQuery({
    queryFn: () => fetchUsers(study),
    queryKey: ["users", study],
  });
};

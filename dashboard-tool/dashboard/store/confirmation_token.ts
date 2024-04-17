import { useQuery } from "react-query";

const fetchToken = async (token: string) => {
  if (!token) return [];

  const path = `/postcovid-dashboard/api/confirmation/${token}`;

  const response = await fetch(path);

  return response;
};

export const useTokens = (token: string) => {
  return useQuery({
    queryFn: () => fetchToken(token),
    queryKey: ["tokens", token],
  });
};

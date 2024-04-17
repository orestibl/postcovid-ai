"use server";
import { revalidateTag } from "next/cache";
import { Criterion, CriterionDetail, FilterData } from "@/types/types";
import { getServerSession } from "next-auth";
import { authOptions } from "@/app/api/auth/[...nextauth]/route";
import { NextResponse } from "next/server";
import useStudyStore from "@/store/study_store";
import { json } from "stream/consumers";

const parseFilterData = (
  filterData: FilterData,
  criteria: Criterion[]
): CriterionDetail[] => {
  const c: CriterionDetail[] = [];

  if (filterData.ageEnabled) {
    c.push({
      id: criteria.filter((c) => c.name === "age")[0].id,
      lower_value: filterData.age[0],
      higher_value: filterData.age[1],
      value: null,
    });
  }
  if (filterData.incomeEnabled) {
    c.push({
      id: criteria.filter((c) => c.name === "salary")[0].id,
      lower_value: null,
      higher_value: null,
      value: filterData.income,
    });
  }
  if (filterData.genderEnabled) {
    c.push({
      id: criteria.filter((c) => c.name === "gender")[0].id,
      lower_value: null,
      higher_value: null,
      value: filterData.gender,
    });
  }
  if (filterData.areaEnabled) {
    c.push({
      id: criteria.filter((c) => c.name === "area")[0].id,
      lower_value: null,
      higher_value: null,
      value: filterData.area,
    });
  }

  return c;
};

export const addFilter = async (
  filterData: FilterData,
  criteria: Criterion[],
  id: string
) => {
  try {
    const session = await getServerSession({ ...authOptions });

    const token = session?.tokens.access_token;

    const res = await fetch(`${process.env.BACKEND_URL}/filter`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        authorization: `Bearer ${token}`,
      },
      body: JSON.stringify({
        name: filterData.name,
        color: filterData.hex,
        studyId: id,
        criteria: parseFilterData(filterData, criteria),
      }),
    });
    return res.json();
  } catch (e) {
    console.log(e);
  }
};

export const removeFilter = async (id: number) => {
  try {
    const response = await fetch(`/postcovid-dashboard/api/filter/${id}`, {
      method: "DELETE",
      headers: {
        "Content-Type": "application/json",
      },
    });

    return response.json();
  } catch (e) {
    console.log(e);
  }
};

export const getFilters = async () => {
  const session = await getServerSession({ ...authOptions });

  const std = useStudyStore.getState().study;

  if(!std) return [];
  
  const study_id = std.id;


  const token = session?.tokens.access_token;
  const endpoint = `${process.env.BACKEND_URL}/filter?study=${study_id}`;

  try {
    const response = await fetch(endpoint, {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
        authorization: `Bearer ${token}`,
      },
      next: { tags: ["filters_load"] },
    });

    const filters = await response.json();

    return filters;
  } catch (e) {
    console.error("Error fetching filters on route filter", e);
    return NextResponse.error();
  }
};

export default async function revalidateData() {
  revalidateTag("filters_load");
  revalidateTag("indicators_load");
}

export const getIndicators = async (
  dateLeft: string | null,
  dateRight: string | null
) => {
  const session = await getServerSession({ ...authOptions });

  const std = useStudyStore.getState().study;

  if (!std) return [];

 const study = std.id;

  const token = session?.tokens.access_token;
  // const study = session?.user.userToStudies[0].study.id;


  const start =
    dateLeft === null || dateLeft === "Invalid Date"
      ? ""
      : `&start=${dateLeft}`;
  const end =
    dateRight === null || dateLeft === "Invalid Date"
      ? ""
      : `&end=${dateRight}`;

  const endpoint = `${
    process.env.BACKEND_URL
  }/indicator?study=${encodeURIComponent(study)}${start}${end}`;

  try {
    const response = await fetch(endpoint, {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
        authorization: `Bearer ${token}`,
      },
      next: { tags: ["indicators_load"] },
    });

    const indicators = await response.json();

    return indicators;
  } catch (e) {
    return NextResponse.error();
  }
};

export const getStudies = async () => {
  console.log("url studies", process.env.BACKEND_URL);

  const response = await fetch(`${process.env.BACKEND_URL}/study`, {
    method: "GET",
    headers: {
      "Content-Type": "application/json",
    },
  });

  return response.json();
};

export const getCriteria = async () => {
  const response = await fetch(`${process.env.BACKEND_URL}/criterion`, {
    method: "GET",
    headers: {
      "Content-Type": "application/json",
    },
  });

  return response.json();
};

export const getZipCodes = async (studyId: string) => {
  console.log("url", process.env.BACKEND_URL);

  const response = await fetch(
    `${process.env.BACKEND_URL}/areas?study=${studyId}`,
    {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
      },
    }
  );

  console.log("response", response.status);

  return response.json();
};

export const getIncomeRanges = async (studyId: string) => {
  const response = await fetch(
    `${process.env.BACKEND_URL}/salary?study=${studyId}`,
    {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
      },
    }
  );
  return response.json();
};

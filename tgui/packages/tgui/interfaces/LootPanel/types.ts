export type SearchItem = {
  name: string;
  path: string;
  uid: string;
} & Partial<{
  icon: string;
  icon_state: string;
}>;

export type SearchGroup = {
  amount: number;
  item: SearchItem;
};

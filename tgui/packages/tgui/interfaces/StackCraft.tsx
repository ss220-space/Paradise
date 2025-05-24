import { useBackend } from '../backend';
import { filter, sortBy, map, reduce } from 'common/collections';
import { flow } from 'common/fp';
import { createSearch } from 'common/string';
import { Window } from '../layouts';
import {
  Box,
  Section,
  NoticeBox,
  Collapsible,
  Input,
  ImageButton,
  Button,
} from '../components';
import { useState } from 'react';

export const StackCraft = () => {
  return (
    <Window width={350} height={500}>
      <Window.Content>
        <Recipes />
      </Window.Content>
    </Window>
  );
};

type RecipesData = {
  amount: number;
  recipes: Recipe[];
};

type Recipe = {
  uid: string;
  required_amount: number;
  result_amount: number;
  max_result_amount: number;
  icon: string;
  icon_state: string;
  image?: string;
};

const Recipes = (_props: unknown) => {
  const { data } = useBackend<RecipesData>();
  const { amount, recipes } = data;
  const [searchText, setSearchText] = useState('');

  const filteredRecipes = filterRecipeList(
    recipes,
    createSearch<Recipe | string>(searchText)
  );
  const [searchActive, setSearchActive] = useState(false);

  return (
    <Section
      fill
      scrollable
      title={'Amount: ' + amount}
      buttons={
        <>
          {searchActive && (
            <Input
              width={12.5}
              value={searchText}
              placeholder={'Find recipe'}
              onInput={(e, value) => setSearchText(value)}
            />
          )}
          <Button
            ml={0.5}
            tooltip="Search"
            tooltipPosition="bottom-end"
            icon="magnifying-glass"
            selected={searchActive}
            onClick={() => setSearchActive(!searchActive)}
          />
        </>
      }
    >
      {filteredRecipes ? (
        <RecipeListBox recipes={filteredRecipes} />
      ) : (
        <NoticeBox>No recipes found!</NoticeBox>
      )}
    </Section>
  );
};

/**
 * Filter recipe list by keys, resursing into subcategories.
 * Returns the filtered list, or undefined, if there is no list left.
 * @param recipeList the recipe list to filter
 * @param titleFilter the filter function for recipe title
 */
const filterRecipeList = (
  recipeList: Recipe[] | Recipe,
  titleFilter: (r: Recipe | string) => boolean
) => {
  const filteredList = flow([
    (recipeList: [string, Recipe][]) =>
      map(recipeList, (entry) => {
        const [title, recipe] = entry;

        if (isRecipeList(recipe)) {
          // If category name matches, return the whole thing.
          if (titleFilter(title)) {
            return entry;
          }

          // otherwise, filter sub-entries.
          return [title, filterRecipeList(recipe, titleFilter)];
        }

        return titleFilter(title) ? entry : [title, undefined];
      }),
    (recipeList: [string, Recipe][]) =>
      filter(recipeList, ([title, recipe]) => recipe !== undefined),
    (recipeList: [string, Recipe][]) =>
      sortBy(recipeList, ([title, recipe]) => title),
    (recipeList: [string, Recipe][]) =>
      sortBy(recipeList, ([title, recipe]) => !isRecipeList(recipe)),
    (recipeList: [string, Recipe][]) =>
      reduce(
        recipeList,
        (obj, [title, recipe]) => {
          obj[title] = recipe;
          return obj;
        },
        {}
      ),
  ])(Object.entries(recipeList));

  return Object.keys(filteredList).length ? filteredList : undefined;
};

/**
 * Check whether recipe is recipe list or plain recipe.
 * Returns true if the recipe is recipe list, false othewise
 * @param recipe recipe to check
 */
const isRecipeList = (recipe: Recipe) => {
  return recipe.uid === undefined;
};

/**
 * Calculates maximum possible multiplier for recipe to be made.
 * Returns number of times, recipe can be made.
 * @param recipe recipe to calculate multiplier for
 * @param amount available amount of resource used in passed recipe
 */
const calculateMultiplier = (recipe: Recipe, amount: number) => {
  if (recipe.required_amount > amount) {
    return 0;
  }

  return Math.floor(amount / recipe.required_amount);
};

type MultipliersProps = {
  recipe: Recipe;
  max_possible_multiplier: number;
};

const Multipliers = (props: MultipliersProps) => {
  const { act } = useBackend();

  const { recipe, max_possible_multiplier } = props;

  const max_available_multiplier = Math.min(
    max_possible_multiplier,
    Math.floor(recipe.max_result_amount / recipe.result_amount)
  );

  const multipliers = [5, 10, 25];

  const finalResult = [];

  for (const multiplier of multipliers) {
    if (max_available_multiplier >= multiplier) {
      finalResult.push(
        <Button
          bold
          color="translucent"
          fontSize={0.85}
          width={'32px'}
          onClick={() =>
            act('make', {
              recipe_uid: recipe.uid,
              multiplier: multiplier,
            })
          }
        >
          {multiplier * recipe.result_amount + 'x'}
        </Button>
      );
    }
  }

  if (multipliers.indexOf(max_available_multiplier) === -1) {
    finalResult.push(
      <Button
        bold
        color="translucent"
        fontSize={0.85}
        width={'32px'}
        onClick={() =>
          act('make', {
            recipe_uid: recipe.uid,
            multiplier: max_available_multiplier,
          })
        }
      >
        {max_available_multiplier * recipe.result_amount + 'x'}
      </Button>
    );
  }

  return <>{finalResult.map((x) => x)}</>;
};

type RecipeListBoxProps = {
  recipes: Recipe[] | Recipe;
};

const RecipeListBox = (props: RecipeListBoxProps) => {
  const { recipes } = props;

  return Object.entries(recipes).map((entry) => {
    const [title, recipe] = entry;
    if (isRecipeList(recipe)) {
      return (
        <Collapsible
          key={title}
          title={title}
          childStyles={{
            marginTop: '0',
            paddingBottom: '0.5em',
            backgroundColor: 'rgba(62, 97, 137, 0.15)',
            border: '1px solid rgba(255, 255, 255, 0.1)',
            borderTop: 'none',
          }}
        >
          <Box p={1} pb={0.25}>
            <RecipeListBox recipes={recipe} />
          </Box>
        </Collapsible>
      );
    } else {
      return <RecipeBox key={title} title={title} recipe={recipe} />;
    }
  });
};

type RecipeBoxProp = {
  title: string;
  recipe: Recipe;
};

const RecipeBox = (props: RecipeBoxProp) => {
  const { act, data } = useBackend<RecipesData>();
  const { amount } = data;
  const { title, recipe } = props;
  const {
    result_amount,
    required_amount,
    max_result_amount,
    uid,
    icon,
    icon_state,
    image,
  } = recipe;

  const resAmountLabel = result_amount > 1 ? `${result_amount}x ` : '';
  const sheetSuffix = required_amount > 1 ? 's' : '';
  const buttonName = `${resAmountLabel}${title}`;
  const tooltipContent = `${required_amount} sheet${sheetSuffix}`;

  const max_possible_multiplier = calculateMultiplier(recipe, amount);

  return (
    <ImageButton
      fluid
      base64={
        image
      } /* Use base64 image if we have it. DmIcon cannot paint grayscale images yet */
      dmIcon={icon}
      dmIconState={icon_state}
      imageSize={32}
      disabled={!max_possible_multiplier}
      tooltip={tooltipContent}
      buttons={
        max_result_amount > 1 &&
        max_possible_multiplier > 1 && (
          <Multipliers
            recipe={recipe}
            max_possible_multiplier={max_possible_multiplier}
          />
        )
      }
      onClick={() =>
        act('make', {
          recipe_uid: uid,
          multiplier: 1,
        })
      }
    >
      {buttonName}
    </ImageButton>
  );
};

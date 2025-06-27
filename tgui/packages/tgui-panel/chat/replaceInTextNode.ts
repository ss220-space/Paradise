/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

type ParseParams = {
  node: Node;
  regex: RegExp;
  createNode: (text: string) => Node;
  captureAdjust?: (text: string) => string;
};

/**
 * Replaces text matching a regular expression with a custom node.
 */
const regexParseNode = (params: ParseParams): ReplaceResult => {
  const { node, regex, createNode, captureAdjust } = params;
  const text = node.textContent;
  const textLength = text.length;
  let nodes: Node[];
  let new_node: Node;
  let match: RegExpExecArray;
  let lastIndex = 0;
  let fragment: Node;
  let n = 0;
  let count = 0;
  while ((match = regex.exec(text))) {
    n += 1;
    // Safety check to prevent permanent
    // client crashing
    if (++count > 9999) {
      return {};
    }
    // Lazy init fragment
    if (!fragment) {
      fragment = document.createDocumentFragment();
    }
    // Lazy init nodes
    if (!nodes) {
      nodes = [];
    }
    const matchText = captureAdjust ? captureAdjust(match[0]) : match[0];
    const matchLength = matchText.length;
    // If matchText is set to be a substring nested within the original
    // matched text make sure to properly offset the index
    const matchIndex = match.index + match[0].indexOf(matchText);
    // Insert previous unmatched chunk
    if (lastIndex < matchIndex) {
      new_node = document.createTextNode(text.substring(lastIndex, matchIndex));
      nodes.push(new_node);
      fragment.appendChild(new_node);
    }
    lastIndex = matchIndex + matchLength;
    // Create a wrapper node
    new_node = createNode(matchText);
    nodes.push(new_node);
    fragment.appendChild(new_node);
  }
  if (fragment) {
    // Insert the remaining unmatched chunk
    if (lastIndex < textLength) {
      new_node = document.createTextNode(text.substring(lastIndex, textLength));
      nodes.push(new_node);
      fragment.appendChild(new_node);
    }
    // Commit the fragment
    node.parentNode.replaceChild(fragment, node);
  }

  return {
    nodes: nodes,
    n: n,
  };
};

type ReplaceResult = {
  n?: number;
  nodes?: Node[];
};

/**
 * Replace text of a node with custom nades if they match
 * a regex expression or are in a word list
 */
export const replaceInTextNode =
  (regex: RegExp, words: string[], createNode: (text: string) => Node) =>
  (node: Node) => {
    let nodes: Node[];
    let result: ReplaceResult;
    let n = 0;

    if (regex) {
      result = regexParseNode({
        node: node,
        regex: regex,
        createNode: createNode,
      });
      nodes = result.nodes;
      n += result.n;
    }

    if (words) {
      let i = 0;
      let wordRegexStr = '(';
      for (let word of words) {
        // Capture if the word is at the beginning, end, middle,
        // or by itself in a message
        wordRegexStr += `^${word}\\s\\W|\\s\\W${word}\\s\\W|\\s\\W${word}$|^${word}\\s\\W$`;
        // Make sure the last character for the expression is NOT '|'
        if (++i !== words.length) {
          wordRegexStr += '|';
        }
      }
      wordRegexStr += ')';
      const wordRegex = new RegExp(wordRegexStr, 'gi');
      if (regex && nodes) {
        for (let a_node of nodes) {
          result = regexParseNode({
            node: a_node,
            regex: wordRegex,
            createNode: createNode,
            captureAdjust: (str: string) => str.replace(/^\W|\W$/g, ''),
          });
          n += result.n;
        }
      } else {
        result = regexParseNode({
          node: node,
          regex: wordRegex,
          createNode: createNode,
          captureAdjust: (str: string) => str.replace(/^\W|\W$/g, ''),
        });
        n += result.n;
      }
    }
    return n;
  };

// Highlight
// --------------------------------------------------------

/**
 * Default highlight node.
 */
const createHighlightNode = (text: string) => {
  const node = document.createElement('span');
  node.setAttribute('style', 'background-color:#fd4;color:#000');
  node.textContent = text;
  return node;
};

/**
 * Highlights the text in the node based on the provided regular expression.
 *
 * @param {Node} node Node which you want to process
 * @param {RegExp} regex Regular expression to highlight
 * @param {(text: string) => Node} createNode Highlight node creator
 * @returns {number} Number of matches
 */
export const highlightNode = (
  node: Node,
  regex: RegExp,
  words: string[],
  createNode = createHighlightNode
) => {
  if (!createNode) {
    createNode = createHighlightNode;
  }
  let n = 0;
  const childNodes = node.childNodes;
  for (let i = 0; i < childNodes.length; i++) {
    const node = childNodes[i];
    // Is a text node
    if (node.nodeType === 3) {
      n += replaceInTextNode(regex, words, createNode)(node);
    } else {
      n += highlightNode(node, regex, words, createNode);
    }
  }
  return n;
};

// Linkify
// --------------------------------------------------------

const URL_REGEX =
  /(?:(?:https?:\/\/)|(?:www\.))(?:[^ ]*?\.[^ ]*?)+[-A-Za-z0-9+&@#/%?=~_|$!:,.;(){}]+/gi;

/**
 * Highlights the text in the node based on the provided regular expression.
 *
 * @param {Node} node Node which you want to process
 * @returns {number} Number of matches
 */
export const linkifyNode = (node: Node) => {
  let n = 0;
  const childNodes = node.childNodes;
  for (let i = 0; i < childNodes.length; i++) {
    const node = childNodes[i];
    const tag = String(node.nodeName).toLowerCase();
    // Is a text node
    if (node.nodeType === 3) {
      n += linkifyTextNode(node);
    } else if (tag !== 'a') {
      n += linkifyNode(node);
    }
  }
  return n;
};

const linkifyTextNode = replaceInTextNode(URL_REGEX, null, (text) => {
  const node = document.createElement('a');
  node.href = text;
  node.textContent = text;
  return node;
});

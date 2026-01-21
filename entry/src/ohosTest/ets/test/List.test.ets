import abilityTest from './Ability.test';
import bugTest from './bug.test';
import aTest from './a.test';

export default function testsuite() {
  abilityTest();
  bugTest()
  aTest()
}